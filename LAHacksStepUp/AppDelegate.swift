//
//  AppDelegate.swift
//  LAHacksStepUp
//
//  Created by Huyanh Hoang on 2016. 4. 30..
//  Copyright © 2016년 LAHacksTeam. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        print(url.host)
        OAuthSwift.handleOpenURL(url)
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
//        let vc = storyboard.instantiateViewControllerWithIdentifier("Dashboard")
//        window!.rootViewController = vc
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
//            NSNotificationCenter.defaultCenter().postNotificationName("Authenticated", object: nil)
        }
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
    }


}

