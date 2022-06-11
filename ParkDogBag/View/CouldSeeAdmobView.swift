//
//  CouldSeeAdmobView.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/6/7.
//

import SwiftUI

struct CouldSeeAdmobView: View {
    //尚未看廣告
    @AppStorage("alreadySeeAdmob") var alreadySeeAdmob: Bool = false
    
    //準備RewardedAd使用
    var rewardAd: RewardedAd = RewardedAd()
    
    var body: some View {
        GeometryReader () { geo in
            let geoWidth = geo.size.width
            let geoHeight = geo.size.height
            VStack{
               
                //按下按鈕時跳出獎勵式廣告，等到看完廣告後獎勵值加一，若未看完就離開則不會加一
                Button(action: {
                    print("See Admob")
                    self.rewardAd.showAd(rewardFunction: {
                        self.alreadySeeAdmob.toggle()
                    })
                }) {
                    Text("準備拿袋子囉～")
                        .foregroundColor(.black)
                        .padding()
                }
                .frame(width: geoWidth*0.75, height: geoHeight*0.1, alignment: .center)
                .foregroundColor(.black)
                .background(Capsule().fill(Color.cyan))
                .position(x:geoWidth/2 , y: geoHeight*0.5)
                
                //因為可能會遇到使用者沒看廣告就跳出，加上Google有說明在跳出廣告前須先載入廣告
                //所以放在button的onAppear來加載廣告，這樣不管是否有看完廣告拿到獎勵都會加載下一個廣告
                .onAppear {
                    self.rewardAd.load()
                }
            }
        }
    }
}

//struct CouldSeeAdmobView_Previews: PreviewProvider {
//    static var previews: some View {
//        CouldSeeAdmobView()
//    }
//}
