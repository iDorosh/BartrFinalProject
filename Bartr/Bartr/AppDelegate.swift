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

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

//Variables
    //Setting storyboards and viewcontrollers
    var window: UIWindow?
    var mainView: UIStoryboard!
    var viewcontroller : UIViewController = UIViewController()
    var tabBarController = UITabBarController()
    
    //Get screen bounds and height to load the proper storyboard
    var screenHeight: NSNumber = NSNumber()
    var bounds: CGRect = CGRect()
    
    //Will hold all and recieved offers from fire base
    var offers = [Offers]()
    var recieverOffers = [Offers]()
    
    //Used to display badges for offers and messages
    var badgeCount : Int = 0
    var messageBadgeCount : Int = 0
    
    //Used to see if the user is signed in
    var userSignedIn : Bool = false
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       
        //Status bar hidden for launch screen and set to light content
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        //Display loading screen
        NSThread.sleepForTimeInterval(2.0);
        
        //Initiate Firebase
        FIRApp.configure()
        
        //Check if the user is signed in
        isUserSignedIn()
        
        //Set proper storyboard
        setProperStoryboard()
        return true
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//

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
    
    //Get current user informtion from firebase
    func getCurrentUserData(){
        DataService.dataService.CURRENT_USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            currentUsernameString = snapshot.value!.objectForKey("username") as! String
            currentUserImageString = snapshot.value!.objectForKey("profileImage") as! String
        })
    }
    
//Functions
    //If stored uid and current user is not nil
    func isUserSignedIn(){
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && FIRAuth.auth()?.currentUser != nil {
            userSignedIn = true
        } else {
            userSignedIn = false
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    func setProperStoryboard(){
        //Checking screen size to load the proper story board
        bounds = UIScreen.mainScreen().bounds
        screenHeight = bounds.size.height
        
        //Setting Main.storyboard as the main story board and loding either sign in screen or the maintabcontroller
        mainView = UIStoryboard(name: "Main", bundle: nil)
        if userSignedIn {
            viewcontroller = mainView.instantiateViewControllerWithIdentifier("MainTabController") as UIViewController
            self.window!.rootViewController = viewcontroller
        } else {
            viewcontroller = mainView.instantiateViewControllerWithIdentifier("Login") as UIViewController
            self.window!.rootViewController = viewcontroller
        }
        
        //Will check if the screen size matches the iPhone 6 screen size and will load that storyboard instead
        if screenHeight == 667 {
            print("iPhone 6")
            // Load Storyboard with name: iPhone4
            var mainView: UIStoryboard!
            mainView = UIStoryboard(name: "iPhone6", bundle: nil)
            if userSignedIn {
                viewcontroller = mainView.instantiateViewControllerWithIdentifier("MainTabController") as UIViewController
                self.window!.rootViewController = viewcontroller
            } else {
                viewcontroller = mainView.instantiateViewControllerWithIdentifier("Login") as UIViewController
                self.window!.rootViewController = viewcontroller
            }
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Observer for incoming offers and will display a badge under the appropriate tabview
    func observeOffers() {
        DataService.dataService.CURRENT_USER_REF.child("offers").observeEventType(.Value, withBlock: { snapshot in
           
            //Setting all offer and recieved offers to 0
            self.offers = []
            self.recieverOffers = []
            
            //Badge count will be reset to 0
            self.badgeCount = 0
            
            //Fetch all offers under the current user from firebase and appends them to offers object
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots{
                    if let offersDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let offer = Offers(key: key, dictionary: offersDictionary)
                        self.offers.insert(offer, atIndex: 0)
                    }
                }
            }
            
            //Looks for recieved offers and appendes them to recieved offers object
            for recieved in self.offers {
                if recieved.offerUID != FIRAuth.auth()?.currentUser?.uid{
                    if recieved.offerStatus == "Delivered"{
                        self.badgeCount += 1
                    } else {
                        if self.badgeCount != 0 {
                            self.badgeCount - 1
                        }
                    }
                    self.recieverOffers.append(recieved)
                }
            }
            
            //Will set the badge count if its not equal to 0
            if self.badgeCount != 0 {
                self.tabBarController.tabBar.items?[4].badgeValue = String(self.badgeCount)
            } else {
                self.tabBarController.tabBar.items?[4].badgeValue = nil
            }
        })
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    //Get Recents on initial load
    func getRecentsObserver(){
        ref.child("Recent").queryOrderedByChild("userId").queryEqualToValue(FIRAuth.auth()?.currentUser!.uid).observeEventType(.Value, withBlock: {
            snapshot in
            self.messageBadgeCount = 0
            if snapshot.exists() {
                let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key : "date", ascending: false)])
                
                for recent in sorted {
                    let count = recent["counter"] as! Int
                    self.messageBadgeCount += count
                }
            }
            //Will set the badge count if its not equal to 0
            print(self.messageBadgeCount)
            if self.messageBadgeCount == 0 {
                self.tabBarController.tabBar.items?[3].badgeValue = nil
            } else {
                self.tabBarController.tabBar.items?[3].badgeValue = String(self.messageBadgeCount)
            }
           
            
        })
    }
    
    //
}

