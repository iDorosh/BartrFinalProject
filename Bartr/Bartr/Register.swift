//
//  Register.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/12/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//


import UIKit
import Firebase

class Register: UIViewController, UITextFieldDelegate {
    
    //Variables
    var croppingEnabled: Bool = true
    var libraryEnabled: Bool = true
    var capturedImage : UIImage = UIImage()
    var base64String : NSString!
    var typeString : String = String()
    var emailText : String = String()
    var passwordText : String = String()
    
    //FireBase URL
    let ref = BASE_URL
    
    //----Outlets----//
    
    var picker:UIImagePickerController?=UIImagePickerController()
    
    //Username text field
    @IBOutlet weak var usernameField: UITextField!
    //Email text field
    @IBOutlet weak var emailField: UITextField!
    //password text field
    @IBOutlet weak var passwordField: UITextField!
    //confirm password text field
    @IBOutlet weak var confirmPasswordField: UITextField!
    //Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    //Profile Image
    @IBOutlet weak var profileImage: UIImageView!
    //Add Image
    @IBOutlet weak var addImage: UIButton!
    //BG Image
    @IBOutlet weak var BG: UIImageView!
    
    
    //----Actions----//
    @IBAction func addImageAction(sender: UIButton) {
        openCamera()
    }
    
    
    @IBAction func openLibrary(sender: AnyObject) {
        openLibrary()
    }
    
    @IBAction func libraryChanged(sender: AnyObject) {
        libraryEnabled = !libraryEnabled
    }
    
    @IBAction func croppingChanged(sender: AnyObject) {
        croppingEnabled = !croppingEnabled
    }


    //Register Action
    @IBAction func registerAction(sender: UIButton) {
        registerClicked()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextFields()
        emailField.text = emailText
        passwordField.text = passwordText
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.BG.addSubview(blurEffectView)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Register.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //----Functions----//
    
    func openCamera()
    {
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            self!.profileImage.image = image
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    func openLibrary(){
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            self.profileImage.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    
    //Text Field Set Up
    func setUpTextFields(){
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === usernameField) {
            emailField.becomeFirstResponder()
        } else if (textField === emailField){
            passwordField.becomeFirstResponder()
        } else if (textField === passwordField){
            confirmPasswordField.becomeFirstResponder()
        } else if (textField === confirmPasswordField) {
            confirmPasswordField.resignFirstResponder()
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
            registerClicked()
        } else {
        }
        return true
    }
    
    //Move scroll view up with keyboard
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == confirmPasswordField){
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0,140), animated: true)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        view.endEditing(true)
    }
    
    //Complete Registration
    func registerClicked(){
        //Send data from text fields to Firebase
        let username = usernameField.text
        let email = emailField.text
        let password = passwordField.text
        let confirmPassword = confirmPasswordField.text
        capturedImage = profileImage.image!
        
        //JPEG to a Base64String to allow saving to Firebase
        var data: NSData = NSData()
        data = UIImageJPEGRepresentation(capturedImage,0.1)!
        
        let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
 
        //Checks if passwords are the same
        if (confirmPassword == password){
            if username != "" && email != "" && password != "" {
                
                // Set Email and Password for the New User.
                DataService.dataService.BASE_REF.createUser(email, password: password, withValueCompletionBlock: { error, result in
                    if error != nil {
                        // There was a problem.
                        self.signupErrorAlert("Oops!", message: "Having some trouble creating your account. Try again.")
                    } else {
                        // Create and Login the New User with authUser
                        DataService.dataService.BASE_REF.authUser(email, password: password, withCompletionBlock: {
                            err, authData in
                            let user = ["provider": authData.provider!, "email": email!, "username": username!, "profileImage" : base64String, "rating" : "5.0"]
                            // Send Data to DataService.swift
                            DataService.dataService.createNewAccount(authData.uid, user: user)
                        })
                        
                        //Saving User uid to User Defaults
                        NSUserDefaults.standardUserDefaults().setValue(result ["uid"], forKey: "uid")
                        
                        //Opens Main Feed
                        self.performSegueWithIdentifier("registerSegue", sender: nil)
                    }
                })
                
            } else {
                //Shows Alert
                signupErrorAlert("Oops!", message: "Don't forget to enter your email, password, and a username.")
            }
        } else {
            //Shows Passwords don't match allert
            signupErrorAlert("Oops", message: "Passwords Don't Match")
        }
        
    }
    
    //Alert
    func signupErrorAlert(title: String, message: String) {
        JSSAlertView().show(self, title: title, text: message)
    }
}

