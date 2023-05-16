//
//  AppDelegate.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/4/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NSFWJSWrapperManager.default
        
        return true
    }
}

