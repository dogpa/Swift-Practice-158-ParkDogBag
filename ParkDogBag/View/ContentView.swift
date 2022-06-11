//
//  ContentView.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/5/27.
//

import SwiftUI

struct ContentView: View {
    //確認是否正在向Firebase讀取資料
    @AppStorage("isLoading") var isLoading = false
    
    //判斷是否看完廣告
    @AppStorage("alreadySeeAdmob") var alreadySeeAdmob: Bool = false
    
    //fBBagLocationViewModel
    @StateObject var fBBagLocationViewModel = FBBagLocationViewModel()
    
    //預設的地圖模式
    @State private var bagShowMode : dogBagShowMode = .mapMode
    
    //存放狗狗的照片
    @State private var image : UIImage = checkDogImage()
    
    //跳出選擇照片頁面
    @State private var isShowPhotoLibrary = false
    
    //嘗試抓User內存入的狗狗照，如果沒有加提示字
    @State private var dogImageInUserDefault = UserDefaults.standard.data(forKey: "dogImage")
    
    var body: some View {
        ZStack{
            GeometryReader() { geo in
                let geoWidth = geo.size.width
                let geoHeight = geo.size.height
                VStack{
                    //第一層
                    //如果firebase還沒取得資料fBBagLocationViewModel.sortedLocationList.count是0的話 先跳progressView
                    if fBBagLocationViewModel.sortedLocationList.count < 1 || isLoading {
                        LoadingProgressView()
                    }else{
                        //第二層
                        //如果袋子數量為0直接顯示袋子不夠
                        if fBBagLocationViewModel.bagsCouldTake < 1 {
                            Text("袋子數量不夠")
                                .position(x: geoWidth/2, y: geoHeight/2)
                        }else{
                            //第三層判斷距離大於25M跳出該有的
                            if fBBagLocationViewModel.sortedLocationList[0].distance > 25  {
                                //HStack開頭
                                HStack{
                                    VStack {
                                        Button(action: {
                                            self.isShowPhotoLibrary = true
                                        }) {
                                            HStack {
                                                Image(uiImage: self.image)
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                            }
                                            .frame(width: 40, height: 40)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                            .padding(.horizontal)
                                        }
                                    }
                                    .sheet(isPresented: $isShowPhotoLibrary) {
                                        ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                                    }
                                    Picker("", selection: $bagShowMode) {
                                        ForEach(dogBagShowMode.allCases, id: \.self) {
                                            Text($0.rawValue)
                                        }
                                    }
                                    .padding()
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                
                                if bagShowMode == .mapMode{
                                    MapView(currentDistanceList: $fBBagLocationViewModel.sortedLocationList,
                                            currentBags: $fBBagLocationViewModel.bagsCouldTake)
                                }else{
                                    ListView(currentDistanceList: $fBBagLocationViewModel.sortedLocationList,
                                             currentBags: $fBBagLocationViewModel.bagsCouldTake)
                                }
                                //HStack結束
                            }else{
                                //小於25M跳出View
                                if isLoading {
                                    LoadingProgressView()
                                }else if !alreadySeeAdmob {
                                    CouldSeeAdmobView()
                                }else{
                                    VStack{
                                        if dogImageInUserDefault == nil{
                                            Text("可在首頁左上角\n點擊狗腳印設定狗狗照片呦")
                                                .frame(width: geo.size.width, height: geo.size.width/4, alignment: .center)
                                                .font(.system(size: 15))
                                                .foregroundColor(.black)
                                                .position(x:geoWidth/2 , y: geoHeight/3)
                                                .multilineTextAlignment(TextAlignment.center)
                                        }else{
                                            Image(uiImage: self.image)
                                                .resizable()
                                                .frame(width: geo.size.width/3, height: geo.size.width/3, alignment: .center)
                                                .cornerRadius(geo.size.width/4)
                                                .padding(.horizontal)
                                                .position(x:geoWidth/2 , y: geoHeight/3)
                                        }
                                        Button {
                                            fBBagLocationViewModel.updateBagsCount(id: fBBagLocationViewModel.FBBagsList[0].id, bags: fBBagLocationViewModel.FBBagsList[0].bags)
                                            self.alreadySeeAdmob = false
                                            fBBagLocationViewModel.fetchBagsData()
                                        } label: {
                                            Text("點我後跟機台拿袋子")
                                        }
                                        .frame(width: geoWidth*0.75, height: geoHeight*0.1, alignment: .center)
                                        .foregroundColor(.black)
                                        .background(Capsule().fill(Color.cyan))
                                        .position(x:geoWidth/2 , y: geoHeight*0.2)
                                    }
                                    .onAppear {
                                        dogImageInUserDefault = UserDefaults.standard.data(forKey: "dogImage")
                                    }
                                }
                            }
                            
                        }
                        //可以的話再判斷距離
                    }
                    //有的話再去判斷袋子數量等等的是
                }
                
                .onAppear {
                    fBBagLocationViewModel.fetchLocationData()
                    fBBagLocationViewModel.fetchBagsData()
                    fBBagLocationViewModel.checkIfLocationServicesIsEnabled()
                }
                
            }
        }
    }
}




///emum如果遵從CaseIterable可以將enum變成Array
enum dogBagShowMode : String, CaseIterable {
    case mapMode = "地圖"
    case listMode = "列表"
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
