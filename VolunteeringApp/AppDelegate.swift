//
//  AppDelegate.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/6/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // this is for push notifications
        registerForPushNotifications(application)
        // --------------------------------------------------
        
        
        GMSServices.provideAPIKey("AIzaSyDoQCB_J9WnOD8hbd-cwdUg3CwIK9iGAy8")
        Parse.initializeWithConfiguration(
            ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "Volunteering"
                configuration.clientKey = ""
                configuration.server = "https://pure-thicket-16559.herokuapp.com/parse"
            })
        )
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        // deals with user logged in persistance
        if PFUser.currentUser() != nil {
            
            
            print("USER IS NOT NIL")
            print(PFUser.currentUser())
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var initialViewController : UIViewController
            if PFUser.currentUser()!["userType"] as! String == "Volunteer" {
                
                initialViewController = mainStoryboard.instantiateViewControllerWithIdentifier("userTabBarController") as UIViewController
                
                let currentDateTime = NSDate()
                let user = PFUser.currentUser()
                var numHistoryEvents = 0
                var numHours = 0
                
                let historyQuery = PFQuery(className: "Event")
                historyQuery.includeKey("host")
                historyQuery.includeKey("attending")
                historyQuery.includeKey("achievements")
                historyQuery.whereKey("startDate", lessThan: currentDateTime)
                historyQuery.whereKey("attending", containsAllObjectsInArray: [user!])
                historyQuery.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
                    if let eventsNotNil = events {
                        numHistoryEvents = eventsNotNil.count
                        
                        for event in eventsNotNil {
                            numHours = numHours + (event["duration"] as! Int)
                        }
                        
                        var achievements = user!["achievements"] as! [String]
                        var existingAchievements: [Int] = []
                        for achievement in achievements {
                            existingAchievements.append(Constant.extractInt(achievement))
                        }
                        
                        if numHistoryEvents >= 1 && !existingAchievements.contains(0) {
                            achievements.append("0 f")
                        }
                        if numHistoryEvents >= 5 && !existingAchievements.contains(1) {
                           achievements.append("1 f")
                        }
                        if numHistoryEvents >= 10 && !existingAchievements.contains(2) {
                            achievements.append("2 f")
                        }
                        if numHistoryEvents >= 15 && !existingAchievements.contains(3) {
                            achievements.append("3 f")
                        }
                        if numHistoryEvents >= 20 && !existingAchievements.contains(4) {
                            achievements.append("4 f")
                        }
                        if numHistoryEvents >= 50 && !existingAchievements.contains(5) {
                            achievements.append("5 f")
                        }
                        
                        if numHours >= 5 && !existingAchievements.contains(6) {
                            achievements.append("6 f")
                        }
                        
                        if numHours >= 20 && !existingAchievements.contains(7) {
                            achievements.append("7 f")
                        }
                        
                        if numHours >= 50 && !existingAchievements.contains(8) {
                           achievements.append("8 f")
                        }
                        
                        if numHours >= 100 && !existingAchievements.contains(9) {
                           achievements.append("9 f")
                        }
                        
                        if numHours >= 150 && !existingAchievements.contains(10) {
                           achievements.append("10 f")
                        }
                        
                        if numHours >= 200 && !existingAchievements.contains(11) {
                        achievements.append("11 f")
                        }
                        
                        print(achievements)
                        
                        user!.setObject(achievements, forKey: "achievements")
                        user?.saveInBackground()
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                }
                
            }
            else {
                initialViewController = mainStoryboard.instantiateViewControllerWithIdentifier("orgTabBarController") as UIViewController
                
            }
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        }
        else {
            print("USER IS NIL")
        }
        

        self.window?.tintColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0) //UIColor.whiteColor()
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UIToolbar.appearance().barTintColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0)
        
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        
        return true
    }
    
    // ------------------ methods regarding push notifications ----------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    // ------------------ methods regarding push notifications ----------------------------
    
    // method dealing with user action in regards to notification settings.
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
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
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // function to ask permission to send notifications
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }


}

