//
//  AppDelegate.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import LNRSimpleNotifications



@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

    let notificationManager = LNRNotificationManager()
    
    var window: UIWindow?
    var offers = [Offers]()
    var recieverOffers = [Offers]()
    var sendOffers = [Offers]()
    var badgeCount : Int = 0
    var getNotifications = NSTimer()
    var tabBarController = UITabBarController()
    
   

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       
        NSThread.sleepForTimeInterval(2.0);
    
      
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)
        
        /*
        let bounds: CGRect = UIScreen.mainScreen().bounds
        let screenHeight: NSNumber = bounds.size.height
        
        var mainView: UIStoryboard!
        mainView = UIStoryboard(name: "Main", bundle: nil)
        let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier("Login") as UIViewController
        self.window!.rootViewController = viewcontroller
        
        if screenHeight == 736  {
            // Load Storyboard with name: iPhone4
            var mainView: UIStoryboard!
            mainView = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier("Login") as UIViewController
            self.window!.rootViewController = viewcontroller
            
        }
        
        if screenHeight == 568{
            // Load Storyboard with name: iPhone4
            var mainView: UIStoryboard!
            mainView = UIStoryboard(name: "iPhone5", bundle: nil)
            let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier("iPhone5") as UIViewController
            self.window!.rootViewController = viewcontroller
            
        }
        
        if screenHeight == 480{
            // Load Storyboard with name: iPhone4
            var mainView: UIStoryboard!
            mainView = UIStoryboard(name: "iPhone4", bundle: nil)
            let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier("iPhone4") as UIViewController
            self.window!.rootViewController = viewcontroller
            
        }
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            var mainView: UIStoryboard!
            mainView = UIStoryboard(name: "iPad", bundle: nil)
            let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier("iPad") as UIViewController
            self.window!.rootViewController = viewcontroller
            
        }*/

        // Override point for customization after application launch.
        FIRApp.configure()
        
        
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        var mainView: UIStoryboard!
        mainView = UIStoryboard(name: "Main", bundle: nil)
        
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && FIRAuth.auth()?.currentUser != nil {
            let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier("MainTabController") as UIViewController
            self.window!.rootViewController = viewcontroller
        } else {
            let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier("Login") as UIViewController
            self.window!.rootViewController = viewcontroller
        }
        
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
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
    
    func observeOffers() {
        DataService.dataService.CURRENT_USER_REF.child("offers").observeEventType(.Value, withBlock: { snapshot in
            // 3
            self.offers = []
            self.sendOffers = []
            self.recieverOffers = []
            
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots{
                    
                    if let offersDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let offer = Offers(key: key, dictionary: offersDictionary)
                        self.offers.insert(offer, atIndex: 0)
                    }
                }
            }
            
            self.badgeCount = 0
            
            for i in self.offers {
                if i.offerUID == FIRAuth.auth()?.currentUser?.uid{
                    self.sendOffers.append(i)
                } else {
                    if i.offerStatus == "Delivered"{
                        self.badgeCount += 1
                    } else {
                        if self.badgeCount != 0 {
                            self.badgeCount - 1
                        }
                    }
                    self.recieverOffers.append(i)
                    
                }
            }
            
            
            if self.badgeCount != 0 {
                self.tabBarController.tabBar.items?[4].badgeValue = String(self.badgeCount)
            } else {
                self.tabBarController.tabBar.items?[4].badgeValue = nil
            }
        })
    }
    
    


}

