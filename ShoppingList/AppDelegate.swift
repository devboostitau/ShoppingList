//
//  AppDelegate.swift
//  ShoppingList
//
//  Created by Eric Alves Brito on 15/09/20.
//  Copyright © 2020 DevBoost. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        if let _ = Auth.auth().currentUser {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tableViewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
            let nc = UINavigationController()
            nc.navigationBar.prefersLargeTitles = true
            nc.viewControllers = [tableViewController]
            window?.rootViewController = nc
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        
        RemoteConfigValues.shared.fetch()
        
    }
}

