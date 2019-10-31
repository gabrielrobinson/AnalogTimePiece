//
//  AppDelegate.swift
//  Time
//
//  Created by Gabriel Robinson on 1/23/19.
//  Copyright © 2019 CS4530. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = ClockViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

