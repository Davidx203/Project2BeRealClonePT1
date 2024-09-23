//
//  AppDelegate.swift
//  Project2BeRealClone
//
//  Created by David Perez on 9/20/24.
//

import Foundation
import UIKit
import ParseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "53K7nf9uYFv8St0i3o6PIWlIle1AxwX0HDtV48y8"
            $0.clientKey = "DYqcl1Dy4F52eIRAKZuh99pNBhISKpRpDRYDtaBx"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: parseConfig)
        return true
    }

}
