//
//  AppDelegate.swift
//  IoTMakerSdk
//
//  Created by AMaster124 on 03/10/2021.
//  Copyright (c) 2021 AMaster124. All rights reserved.
//

import UIKit
import IoTMakerSdk

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IoTMakerSdk.configure(isPublic: false)
        return true
    }
}

