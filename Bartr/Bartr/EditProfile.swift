//
//  EditProfile.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/19/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import ALCameraViewController
import SCLAlertView
import FirebaseDatabase

class EditProfile: UIViewController, UITextFieldDelegate {
    
    @IBAction func backToEditProfile(segue: UIStoryboardSegue){}

    
    
//Outlets
    @IBOutlet weak var signinButton: UIButton!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
   
//Actions
    
    @IBAction func signInAction(sender: UIButton) {
        signinSignout()
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//UI
    override func viewWillAppear(animated: Bool) {
        if signUpSkipped {
            signinButton.setTitle("Sign In", forState: .Normal)
        } else {
            signinButton.setTitle("     Sign Out", forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Functions
    //Sign in or sign out current user
    func signinSignout(){
        if signUpSkipped {
            signUpSkipped = false
            let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
            UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
        } else {
            DataService.dataService.CURRENT_USER_REF.removeAllObservers()
            DataService.dataService.BASE_REF.removeAllObservers()
            DataService.dataService.POST_REF.removeAllObservers()
            DataService.dataService.USER_REF.removeAllObservers()
            let alertView = SCLAlertView()
            alertView.addButton("Sign Out", target:self, selector:#selector(self.signOutCallBack))
            alertView.addButton("Cancel"){alertView.dismissViewControllerAnimated(true, completion: nil)}
            alertView.showCloseButton = false
            
            alertView.showWarning("Sign out", subTitle: "Sign out current user?")
        }
    }
    
    //Sign user out when the alert view confirm button is clicked
    func signOutCallBack() {
        try! FIRAuth.auth()!.signOut()
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
}
