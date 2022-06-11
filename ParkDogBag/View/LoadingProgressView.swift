//
//  ProgressView.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/6/2.
//

import SwiftUI

struct LoadingProgressView: View {
    var body: some View {
        GeometryReader() { geo in
            //顯示ProgressView與自定義的文字內容
            VStack{
                ProgressView("資料擷取中...")
                .position(x: geo.size.width/2, y: geo.size.height/2)
            }     
        }
        
        
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingProgressView()
    }
}
