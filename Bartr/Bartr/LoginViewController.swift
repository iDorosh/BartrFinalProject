//
//  LoginViewController.swift
//  Project X
//
//  Created by Ian Dorosh on 4/25/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController, UITextFieldDelegate {
    //Will bring the user back to the login screen
    @IBAction func backToLogin(segue: UIStoryboardSegue){}
    
    //----Data----//
    
    //Email string from text field
    var emailTextFieldText : String = String()
    //password string from text field
    var passwordTextFieldText : String = String()
    
    //FireBase URL
    let ref = Firebase(url: BASE_URL)
    
    //----Outlets----//
    
    //User Email
    @IBOutlet weak var loginEmail: UITextField!
    //User Password
    @IBOutlet weak var loginPassword: UITextField!
    //Log In Button
    @IBOutlet weak var logInBttn: UIButton!
    //Register Button
    @IBOutlet weak var registerBttn: UIButton!
    //Skip Button
    @IBOutlet weak var skipBttn: UIButton!
    //Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    //Background Img
    @IBOutlet weak var BG: UIImageView!
    
    //----Actions----//
    
    //Log In Button Action
    @IBAction func logInAction(sender: UIButton) {
        logInClicked()
    }
    
    //Register Button Action
    @IBAction func registerAction(sender: UIButton) {
        registerClicked()
    }
    
    @IBAction func forgotPassword(sender: UIButton) {
        forgotPassword()
    }
    
    
    //Skip Button Action
    @IBAction func skipAction(sender: UIButton) {
        skipClicked()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .Default
        setUpTextFields()
        setUpBackground()
        setUpTapRecognizer()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && DataService.dataService.CURRENT_USER_REF.authData != nil {
            self.performSegueWithIdentifier("skipLoginSegue", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //----Functions----//
    
    //Sends current email a temporary password
    func forgotPassword(){
        ref.resetPasswordForUser(loginEmail.text) { (error : NSError!) in
            if ((error) != nil) {
                print(error)
            } else {
                print("Password reset email sent successfully!")
            }
        }
    }
    
    //Blurr effect for the background image
    func setUpBackground(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.BG.addSubview(blurEffectView)
    }
    
    //Tap recognizer to minimize keyboard
    func setUpTapRecognizer(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Text Field Set Up
    func setUpTextFields(){
        loginEmail.delegate = self
        loginPassword.delegate = self
    }
    
    //Next text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === loginEmail) {
            loginPassword.becomeFirstResponder()
        } else if (textField === loginPassword) {
            loginPassword.resignFirstResponder()
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
            logInClicked()
        } else {
        }
        return true
    }
    
    //Resets view
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == loginPassword){
        scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        }
    }
    
    //Sets proper view postition when keyboard pops up
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == loginEmail){
        scrollView.setContentOffset(CGPointMake(0,150), animated: true)
        } else if (textField == loginPassword){
            scrollView.setContentOffset(CGPointMake(0,150), animated: true)
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Resets view offset
        scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        view.endEditing(true)
    }
    
    //Log In Button has been clicked
    func logInClicked(){
            let email = loginEmail.text
            let password = loginPassword.text
            
            if email != "" && password != "" {
                // Login with the Firebase's authUser method
                DataService.dataService.BASE_REF.authUser(email, password: password, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print(error)
                        self.loginErrorAlert("Oops!", message: "Check your username and password.")
                    } else {
                        // Storing User UID
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                        // Enter Main Feed
                        self.performSegueWithIdentifier("skipLoginSegue", sender: nil)
                    }
                })
            } else {
                // There was a problem
                loginErrorAlert("Oops!", message: "Don't forget to enter your email and password.")
            }
    }
    
    //Sending email and password to the register screen if they were filled out.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "registerNew" {
                let signUp : Register = segue.destinationViewController as! Register
                let email = loginEmail.text
                let password = loginPassword.text
            if email != "" {
                signUp.emailText = email!
                signUp.passwordText = password!
            }
        }
    }
    
    //Register Button has been clicked
    func registerClicked(){
            performSegueWithIdentifier("registerNew", sender: nil)
    }
    
    //Skip Button has been clicked
    func skipClicked(){
        performSegueWithIdentifier("skipLoginSegue", sender: nil)
    }
    
    //Show alert view
    func loginErrorAlert(title: String, message: String) {
        JSSAlertView().show(self, title: title, text: message)
    }

}
