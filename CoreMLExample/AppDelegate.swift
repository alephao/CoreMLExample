//
//  AppDelegate.swift
//  CoreMLExample
//
//  Created by Aleph Retamal on 6/6/17.
//  Copyright © 2017 WWDC17. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: UI
    
    var window: UIWindow?
    
    // MARK: UIApplicationDelegate
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        let rootController = ViewController()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        
        window.rootViewController = rootController
        self.window = window
        
        return true
    }
}
