//
//  MapView.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/5/30.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: View {
    
    //透過Binding 取得存在Firestore的狗便袋List
    @Binding var currentDistanceList: [LocationInfo2D]
    @Binding var currentBags : Int
    @StateObject var fbVM: FBBagLocationViewModel = FBBagLocationViewModel()
      
      //MapUserTrackingMode的追蹤模式
      @State private var trackMode = MapUserTrackingMode.none
      
      var body: some View {
          //ZStack最底層是一個Map，上一層為一層GeometryReader
          ZStack{
              
              //Map內顯示使用者的位置，並且在MapAnnotation放入locationVM.locations透過coordinate顯示位置
              //透過ocationVM.locations裡面的地理坐標計算使用者的直線距離顯示在Text內
              //第二個Text為locationVM.locations地理位置名稱
              Map(coordinateRegion: $fbVM.region, showsUserLocation: true, userTrackingMode: $trackMode  , annotationItems: currentDistanceList) { item in
                  MapAnnotation(coordinate: item.coordinate, content: {
                      VStack{
                          //Text("\(item.distance)")
                          Text("\(fbVM.getKOrKMDString(distance: item.distance))")
                              .font(.system(size: 15))
                              .foregroundColor(.red)
                          Text(item.locationName)
                              .font(.system(size: 15))
                              .foregroundColor(.black)
                          Image(systemName: "hare.fill")
                              .foregroundColor(.brown)
                      }
                  })
              }
                  .ignoresSafeArea()
                  .accentColor(.cyan)
                  .onAppear {
                      fbVM.checkIfLocationServicesIsEnabled()
                      //fbVM.fetchLocationData()
                  }
              
              //GeometryReader內包一層ZStack第一層放LocationButton
              //使用者按下後會回到實際位置，不按時可自由滑動地圖
              //第二層放入Text顯示使用者目前的經緯度資訊
              GeometryReader{ geo in
                  ZStack{
                      LocationButton(.currentLocation){
                          fbVM.requestUserLocation()
                      }
                      .foregroundColor(.white)
                      .cornerRadius(10)
                      .labelStyle(.iconOnly)
                      .symbolVariant(.fill)
                      .tint(.blue)
                      .position(x: CGFloat(geo.size.width*0.9), y: CGFloat(geo.size.height*0.05))
                      
                      Text("\(currentBags)")
                          .frame(width: geo.size.width/10, height: geo.size.width/10)
                          .background(Circle().fill(.cyan))
                          .position(x: CGFloat(geo.size.width * 0.1), y: CGFloat(geo.size.height * 0.045))
                      
                      //MARK: 判斷袋子數量大於0與網路資料的公園列表已經讀取到再顯示
                      if currentDistanceList.count > 0 {
                              Text("\(currentDistanceList[0].locationName)\n\(fbVM.getKOrKMDString(distance: currentDistanceList[0].distance))")
                                  .frame(width: 300, height: 60, alignment: .center)
                                  .background(RoundedRectangle(cornerRadius: 20).fill(.yellow))
                                  .tint(.black)
                                  .position(x: CGFloat(geo.size.width/2), y: CGFloat(geo.size.height*0.93))
                      }
                  }
              }
          }
      }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
