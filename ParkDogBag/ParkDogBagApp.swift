//
//  ParkDogBagApp.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/5/27.
//

/*
 <key>GADIsAdManagerApp</key>
 <true/>
 */
import SwiftUI
import GoogleMobileAds
import Firebase

@main
struct ParkDogBagApp: App {
    
    init(){
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
