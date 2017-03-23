//
//  AppDelegate.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/05/15.
//  Copyright (c) 2015 Daniel Karsh. All rights reserved.
//

import UIKit
import GooglePlaces

@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
  
    private let useRemoteStoreSettingDefault    = true
    private let baseURLSettingKey               = "base_url_setting"
    private let baseURLSettingDefault           = "https://m.crisscrosstheapp.com/api//"
    private let useRemoteStoreSettingKey        = "use_remote_store_setting"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    
    func applicationDidBecomeActive(application: UIApplication) {
      
    }

    func applicationWillTerminate(application: UIApplication) {

    }

    // MARK: Notifications

    // MARK: Private Helpers

    private func customizeAppAppearance() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        let tintColor = Color.primaryColor
        window?.tintColor = tintColor
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 20)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        UINavigationBar.appearance().translucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name: "OpenSans", size: 17)!],
            forState: .Normal
        )
    }

    private func baseURLFromString(string: String) -> NSURL {
        var baseURLString = string
        // Append forward slash if needed to ensure proper relative URL behavior
        let forwardSlash: Character = "/"
        if !baseURLString.hasSuffix(String(forwardSlash)) {
            baseURLString.append(forwardSlash)
        }
        return NSURL(string: baseURLString) ?? NSURL(string: baseURLSettingDefault)!
    }


    
    private func tabViewControllersForStore(store: StoreType?) -> [UIViewController] {
        guard let store = store else { return [] }
        let matchesViewModel = MatchesViewModel(store: store)
        let matchesViewController = MatchesViewController(viewModel: matchesViewModel)
        let matchesNavigationController = UINavigationController(rootViewController: matchesViewController)
        matchesNavigationController.tabBarItem = UITabBarItem(
            title: matchesViewModel.title,
            image: UIImage(named: "FootballFilled"),
            selectedImage: UIImage(named: "FootballFilled")
        )

        let rankingsViewModel = RankingsViewModel(store: store)
        let rankingsViewController = RankingsViewController(viewModel: rankingsViewModel)
        let rankingsNavigationController = UINavigationController(rootViewController: rankingsViewController)
        rankingsNavigationController.tabBarItem = UITabBarItem(
            title: rankingsViewModel.title,
            image: UIImage(named: "Crown"),
            selectedImage: UIImage(named: "CrownFilled")
        )
        return [matchesNavigationController, rankingsNavigationController]
    }
}


