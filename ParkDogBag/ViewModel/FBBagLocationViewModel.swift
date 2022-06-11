//
//  FBBagLocationViewModel.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/5/30.
//

import Foundation
import Firebase
import FirebaseFirestore
import MapKit
import SwiftUI


/// 存放初始的地理位置與地圖比例尺
enum MapDetails {
    static let originLocation = CLLocationCoordinate2D(latitude: 24.138419004819387, longitude: 121.27559334860734)
    static let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
}


final class FBBagLocationViewModel : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    //是否正在讀取資料
    
    @AppStorage("isLoading") var isLoading = false
    
    //儲存存在Firebase的地理坐標
    @Published var FBLocationList = [BagLocationInfo]()
    
    //儲存轉換後2D的座標
    @Published var locationList = [LocationInfo2D]()
    
    
    //使用者移動位置後重新排序距離的List
    @Published var sortedLocationList = [LocationInfo2D(locationName: "世界的角落", coordinate: CLLocationCoordinate2D(latitude: 24.138419004819387, longitude: 121.27559334860734), distance: 0)]
    
    
    //存放User的經緯度座標位置的CLLocation，用於計算指定距離使用
    @Published var userLocationForNow = CLLocation(latitude: 0, longitude: 0)
    
    
    //取得使用者授權前的MAP顯示位置與比例尺透過MapDetails的值來顯示
    @Published var region = MKCoordinateRegion(center: MapDetails.originLocation, span: MapDetails.span)
    
    
    @Published var bagsCouldTake = 0
    
    //儲存存在Firebase的地理坐標
    @Published var FBBagsList = [ParkBag]()
    
    
    //建立Firestore
    let firestore = Firestore.firestore()
    
    ///取得資料後透過Main Thread更新畫面，將Firestore的狗便袋位置並存入locationList
    func fetchLocationData () {
        print(#function)
        isLoading = true
        firestore.collection("Park").getDocuments { data, error in
            if error == nil {
                if let data = data {
                    
                    self.FBLocationList = data.documents.map { thing in
                        return BagLocationInfo(id: thing.documentID,
                                               parkName: thing["parkName"] as? String ?? "",
                                               parkGeoPoint: thing["parkGeoPoint"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0))
                    }
                    self.locationList = []
                    for i in self.FBLocationList.indices{
                        
                        self.locationList.append(
                            LocationInfo2D(locationName: self.FBLocationList[i].parkName,
                                           coordinate: CLLocationCoordinate2D(latitude: self.FBLocationList[i].parkGeoPoint.latitude, longitude: self.FBLocationList[i].parkGeoPoint.longitude),
                                           distance: self.userLocationForNow.distance(from: CLLocation(latitude: CLLocationDegrees(self.FBLocationList[i].parkGeoPoint.latitude), longitude: CLLocationDegrees(CLLocationDegrees(self.FBLocationList[i].parkGeoPoint.longitude))))
                                          ))
                    }
                    let afterSortedLocationList = self.locationList.sorted {
                        $0.distance < $1.distance
                    }
                    DispatchQueue.main.async {
                        self.sortedLocationList = afterSortedLocationList
                        //print("\n\nfatch inside", "\n\n", self.sortedLocationList)
                    }
                    self.isLoading = false
                }
            }else{
                self.isLoading = false
                print(error!)
            }
        }
    }
    
    ///取得資料後透過Main Thread更新畫面，將Firestore的狗便袋次數位置並存入locationList
    func fetchBagsData () {
        print(#function)
        isLoading = true
        firestore.collection("Bag").getDocuments { data, error in
            if error == nil {
                if let data = data {
                    DispatchQueue.main.async {
                        self.FBBagsList = data.documents.map { thing in
                            return ParkBag(id: thing.documentID,
                                           bags: thing["bags"] as? Int ?? 0)
                        }
                        self.bagsCouldTake = self.FBBagsList[0].bags
                        self.isLoading = false
                    }
                }
            }else{
                self.isLoading = false
                print(error!)
            }
        }
    }
    
    
    /// 更新狗便袋數量，每次減一
    ///
    /// - Parameters:
    ///     - id: 準備更動的狗便袋ID
    ///     - thing: 準備更動
    func updateBagsCount(id:String, bags: Int) {
        firestore.collection("Bag").document(id).setData(["bags" : bags - 1], merge: true) { error in
            if error != nil {
                print(error!)
            }
        }
    }
    
    
    //取得CLLocationManager
    var locationManager =  CLLocationManager()
    
    ///判斷使用者的權限
    func checkIfLocationServicesIsEnabled () {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }else{
            print("可通知使用者去設定開啟地理位置權限")
        }
    }
    
    /// 取得使用者目前所在的位置，並顯示在MAP當中
    func requestUserLocation () {
        locationManager.requestLocation()
        DispatchQueue.main.async { [self] in
            self.region = MKCoordinateRegion(center: self.locationManager.location!.coordinate , span: MapDetails.span)
        }
    }
    
    /// 確認使用者的授權，若允許存取將使用者的位置指派給region
    private func checkLocationAuthorization () {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("你的地理位置權限受限")
        case .denied:
            print("你的地理位置沒有獲得你的允許，可至設定中開啟權限")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? MapDetails.originLocation, span: MapDetails.span)
        @unknown default:
            break
        }
    }
    
    /// 使用者若改變使用授權，再次檢查授權狀況
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    /// 若使用者的位置改變，將最新的位置存入locationforCL，locationStr存入將使用者的經緯度
    /// 計算新的使用者與各個狗便袋位置的座標並依照距離重新排序後存入sortedLocationList
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocationForNow = locations[0]
        print("目前位置 緯度：\(locations[0].coordinate.latitude)  經度：\(locations[0].coordinate.longitude) userLocationForNow\(userLocationForNow)")
        var adjustDistanceArray = [LocationInfo2D]()
        for i in locationList.indices {
            adjustDistanceArray.append(LocationInfo2D(locationName: locationList[i].locationName, coordinate: locationList[i].coordinate, distance: locations[0].distance(from: CLLocation(latitude: CLLocationDegrees(self.locationList[i].coordinate.latitude), longitude: CLLocationDegrees(self.locationList[i].coordinate.longitude)))))
        }
        let afterSortedLocationList = adjustDistanceArray.sorted {
            $0.distance < $1.distance
        }
        sortedLocationList = afterSortedLocationList
    }
    
    ///若遭遇Error則列印Error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    /// 若直線距離大於1000則除1000並顯示公里
    /// 小於1000則顯示公司
    /// 統一顯示小數點三位數
    ///  - Parameters :
    ///      - distance : 直線距離的Double值
    /// - Returns: 回傳指定字串Double大於1000回傳公里，小於則回傳公尺
    func getKOrKMDString (distance: Double) -> String {
        if distance > 1000 {
            return "\(String(format: "%.1f", distance/1000)) 公里"
        }else{
            return "\(String(format: "%.1f", distance)) 公尺"
        }
    }
}

