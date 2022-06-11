//
//  FBLocation.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/5/30.
//

import FirebaseFirestore
import MapKit

/// 與Firebase讀取地理資料
struct BagLocationInfo: Identifiable {
    var id : String
    var parkName: String
    var parkGeoPoint: GeoPoint
}


/// 自定義Struct顯示地理位置名稱、座標，轉換成自己List用的
struct LocationInfo2D: Identifiable {
    let id = UUID()
    var locationName: String
    var coordinate: CLLocationCoordinate2D
    var distance: Double
}


/// 與Firebase讀取狗便袋數量資料
struct ParkBag: Identifiable {
    var id : String
    var bags: Int
}
