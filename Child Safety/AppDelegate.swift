//
//  AppDelegate.swift
//  Child Safety
//
//  Created by Amir Shavit on 5/20/15.
//  Copyright (c) 2015 Amir & Geva. All rights reserved.
//

import UIKit
//import EstimoteSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let cloudManager = ESTCloudManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        BeaconManager.sharedInstance
        initNotifications(application)
        
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func initNotifications(application: UIApplication)
    {
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(settings)
    }

    // MARK: - Push Notification Delegate
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        // After device is registered in iOS to receive Push Notifications,
        // device token has to be sent to Estimote Cloud.
        cloudManager.registerDeviceForRemoteManagement(deviceToken, completion:
            { (error) -> Void in
                println(error)
            })
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings)
    {
        println("application didRegisterUserNotificationSettings: %@", notificationSettings)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
    {
        // Verify if push is comming from Estimote Cloud and is related
        // to remote beacon management
        if (ESTBulkUpdater.verifyPushNotificationPayload(userInfo))
        {
            // pending settings are fetched and performed automatically
            // after startWithCloudSettingsAndTimeout: method call
            ESTBulkUpdater.sharedInstance().startWithCloudSettingsAndTimeout(60 * 60)
        }
    
        completionHandler(UIBackgroundFetchResult.NewData);
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        println("application didReceiveLocalNotification: %@", notification)
    }
}

