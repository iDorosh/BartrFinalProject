//
//  LoginViewController.swift
//  Project X
//
//  Created by Ian Dorosh on 4/25/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class LoginViewController: UIViewController, UITextFieldDelegate {
    //Will bring the user back to the login screen
    @IBAction func backToLogin(segue: UIStoryboardSegue){}
    
    //----Data----//
    
    //Email string from text field
    var emailTextFieldText : String = String()
    //password string from text field
    var passwordTextFieldText : String = String()
    
    var alertController = UIAlertController()
    
    var errorMessage : String = ""
    
    var defaultColor = UIColor()
    var defaultBorderColor = UIColor()
    
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
        enterEmail()
    }
    
    
    //Skip Button Action
    @IBAction func skipAction(sender: UIButton) {
        skipClicked()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultColor = loginEmail.textColor!
        defaultBorderColor = loginEmail.backgroundColor!
        UIApplication.sharedApplication().statusBarStyle = .Default
        setUpTextFields()
        setUpBackground()
        setUpTapRecognizer()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        alertController = showLoading("Signing In...")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //----Functions----//
    
    //Sends current email a temporary password
    func forgotPasswordSend(email : String){
        
        FIRAuth.auth()?.sendPasswordResetWithEmail(loginEmail.text!) { error in
            if error != nil {
                self.errorResetingPassword("Error", subTitle: "\(error)")
            } else {
                self.success("Email Sent", subTitle: "Follow the instructions in your email to reset your password")
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
        loginEmail.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        loginPassword.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    
    
    //Next text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === loginEmail) {
            loginPassword.becomeFirstResponder()
        } else if (textField === loginPassword) {
            loginPassword.resignFirstResponder()
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
            //self.presentViewController(alertController, animated: true, completion: nil)
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
    
    func textViewDidChange(textView: UITextView) {
        if textView === loginEmail{
            loginEmail.layer.borderColor = defaultBorderColor.CGColor
        } else {
            loginPassword.layer.borderColor = defaultBorderColor.CGColor
        }
        textView.textColor = defaultColor
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Resets view offset
        scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        view.endEditing(true)
    }
    
    //Log In Button has been clicked
    func logInClicked(){
        errorMessage = ""
        
            let email = loginEmail.text
            let password = loginPassword.text
            
            if email != "" && password != "" {
                dismissKeyboard()
                self.presentViewController(alertController, animated: true, completion: nil)
                // Login with the Firebase's authUser method
                
                FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
                    if error != nil{
                        if let errorCode = FIRAuthErrorCode(rawValue: error!.code) {
                            switch (errorCode) {
                            case .ErrorCodeInvalidEmail:
                                self.errorMessage = "Invalid"
                                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                                self.errorSigningIn("Oops!", subTitle: "Please enter a valid email")
                            case .ErrorCodeWrongPassword:
                                self.errorMessage = "Password"
                                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                                self.errorSigningIn("Oops!", subTitle : "The specified password is invalid")
                            case .ErrorCodeUserNotFound:
                                self.errorMessage = "Invalid"
                                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                                self.errorSigningIn("Oops!", subTitle: "This email is not associated with an account")
                            default:
                                print(errorCode.rawValue)
                            }
                        }
                    }
                    else {
                        // Storing User UID
                        NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: "uid")
                        self.alertController.dismissViewControllerAnimated(true, completion: nil)
                        // Enter Main Feed
                        self.success("Signed In!", subTitle: "Welcome to Bartr")
                        self.performSegueWithIdentifier("skipLoginSegue", sender: nil)
                    }
                }
                
                
            } else {
                // There was a problem
                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                errorSigningIn("Oops!", subTitle: "Don't forget to enter your email and password.")
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
    
    func success(title : String, subTitle : String){
        let alertView = SCLAlertView()
        alertView.showSuccess(title, subTitle: subTitle)
    }
    
    func errorResetingPassword(title : String, subTitle : String){
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.addButton("Try Again") {
            self.enterEmail()
        }
        alertView.addButton("Cancel") {
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showSuccess(title, subTitle: subTitle) 
    }
    
    func errorSigningIn(title : String, subTitle : String){
        let alertView = SCLAlertView()
        alertView.addButton("Done", target:self, selector:#selector(setFirstResponder))
        alertView.showCloseButton = false
        
        alertView.showError(title, subTitle: subTitle)
    }
    
    //Register Button has been clicked
    func registerClicked(){
            performSegueWithIdentifier("registerNew", sender: nil)
    }
    
    //Skip Button has been clicked
    func skipClicked(){
        performSegueWithIdentifier("skipLoginSegue", sender: nil)
    }
    
    
    func setFirstResponder(){
        if errorMessage == "Email"{
        loginEmail.becomeFirstResponder()
            setError(loginEmail)
        } else if errorMessage == "Invalid"{
            loginEmail.becomeFirstResponder()
            setError(loginEmail)
        }else {
           loginPassword.becomeFirstResponder()
           setError(loginPassword)
        }
    }
    
    func enterEmail(){
        let alert = SCLAlertView()
        alert.showCloseButton = false
        let txt = alert.addTextField("Enter Email")
        alert.addButton("Reset Password") {
            self.forgotPasswordSend(txt.text!)
        }
        alert.addButton("Cancel"){ alert.dismissViewControllerAnimated(true, completion: nil)}
        alert.showEdit("Forgot Password", subTitle: "Please enter an email address so we can send you a password reset link")
    }

    
    func setError(textField : UITextField){
        textField.layer.borderColor = hexStringToUIColor("#f27163").CGColor
        textField.layer.cornerRadius = 10.0
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
    }
    
    func setGoodToGo(textField : UITextField){
        textField.layer.borderColor = hexStringToUIColor("#91c769").CGColor
        textField.layer.cornerRadius = 10.0
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
    }

    

}
