//
//  ListView.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/5/30.
//

import SwiftUI

struct ListView: View {
    //接收已經排定好距離順序的狗便袋清單
    @Binding var currentDistanceList: [LocationInfo2D]
    
    //接收目前狗便袋的數量
    @Binding var currentBags : Int
    
    //FBBagLocationViewModel
    @StateObject var fBBagLocationViewModel = FBBagLocationViewModel()
    
    var body: some View {
        VStack(){
            Text("目前袋子數量：\(currentBags)")
            
            //透過List顯示排序好的狗便袋數量
            List(currentDistanceList) {thing in
                VStack{
                    Text(thing.locationName)
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                    Text("\(fBBagLocationViewModel.getKOrKMDString(distance: thing.distance))")
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                }
            }
        }
    }
}



//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView()
//    }
//}
