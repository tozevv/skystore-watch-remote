//
//  AppDelegate.swift
//  Watch Remote
//
//  Created by Vieira, Antonio (Technology) on 31/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?

    var wcsession: WCSession? {
        didSet {
            if let wcsession = wcsession {
                wcsession.delegate = self
                wcsession.activateSession()
            }
        }
    }
      
    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        let healthStore = HKHealthStore()
        healthStore.handleAuthorizationForExtensionWithCompletion {(success, error) -> Void in
            // Add anything you need here after authorization
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("data received")
        if let keypressed = message["keypressed"] as? String {
            print("pressing key:\(keypressed)")
            
            RokuRemote.Current().sendCommand(keypressed)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        if WCSession.isSupported() && wcsession == nil {
            print("launched session")
            wcsession = WCSession.defaultSession()
        }

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

 
}

