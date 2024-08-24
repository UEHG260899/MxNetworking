//
//  AppDelegate.swift
//  MxNetworking
//
//  Created by UEHG260899 on 02/15/2023.
//  Copyright (c) 2023 UEHG260899. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let rootViewController = MainViewController()
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let shouldShowNavBar = (viewController is MainViewController)
        navigationController.setNavigationBarHidden(shouldShowNavBar, animated: true)
    }
}
