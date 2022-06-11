//
//  RewardedAd.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/6/7.
//

import Foundation
import GoogleMobileAds

final class RewardedAd {
    
    //MARK: 測試時先使用官方的Client ID ，正式上架時換成自己單元的ID
    private let rewardId = "ca-app-pub-3940256099942544/1712485313"
    
    //變數GADRewardedAd
    var rewardedAd: GADRewardedAd?
    
    //初時化時執行自定義load function
    init() {
        load()
    }
    
    
    ///讀取廣告，準備顯示
    func load(){
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: rewardId, request: request, completionHandler: {rewardedAd, error in
            if error != nil {
                // loading the rewarded Ad failed :(
                return
            }
            self.rewardedAd = rewardedAd
        })
    }
    
    ///顯示廣告
    func showAd(rewardFunction: @escaping () -> Void) -> Bool {
        guard let rewardedAd = rewardedAd else {
            return false
        }
        
        guard let root = UIApplication.shared.keyWindowPresentedController else {
            return false
        }
        rewardedAd.present(fromRootViewController: root, userDidEarnRewardHandler: rewardFunction)
        return true
    }
    
}

//跳出廣告頁面的extension
extension UIApplication {
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        return viewController
    }
}
