//
//  CameraController.swift
//  Bartr
//
//  Created by Ian Dorosh on 7/12/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class CameraController: UIViewController {

//Outlers
    //Sign in view when the user isnt logged in
    @IBOutlet weak var signin: UIView!
    //Background Image
    @IBOutlet weak var bgImage: UIImageView!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
   
//Actions

    @IBAction func backtoMain(sender: UIButton) {
        performSegueWithIdentifier("BacktoMain", sender: self)
    }
    @IBAction func startNewListing(sender: UIButton) {
        performSegueWithIdentifier("showNewListing", sender: self)
    }
    @IBAction func signInBttn(sender: UIButton) {
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//UI
    override func viewDidLoad() {super.viewDidLoad()}
    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}
    override func viewWillAppear(animated: Bool) {
        loadUI()
    }
    
    func loadUI(){
        if signUpSkipped {
            signin.hidden = false
            self.tabBarController?.tabBar.hidden = false
        } else {
            signin.hidden = true
            self.tabBarController?.tabBar.hidden = true
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            self.bgImage.addSubview(blurEffectView)
        }
    }
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
}
