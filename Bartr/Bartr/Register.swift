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
    
    @IBOutlet weak var userNameRequirements: UILabel!
    
    @IBOutlet weak var passwordRequirements: UILabel!
    
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    var alertController = UIAlertController()
    
    var errorMessage : String = ""
    
    var defaultColor = UIColor()
    var textColor = UIColor()
    
    var usernameExists = false
    
    var users : [String] = []
    
    
    
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
        defaultColor = emailField.backgroundColor!
        textColor = userNameRequirements.textColor!
        getUsers()
        
        alertController = showLoading("Creating Account...")
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
        usernameField.addTarget(self, action: #selector(self.usernameFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        emailField.addTarget(self, action: #selector(self.emailFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        passwordField.addTarget(self, action: #selector(self.passwordFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        confirmPasswordField.addTarget(self, action: #selector(self.confirmPasswordDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func usernameFieldDidChange(textView: UITextView) {
        var uExists : Bool = false
        var length : Bool = false
        var space : Bool = false
        
        if users.contains(usernameField.text!.lowercaseString){
            uExists = true
            setError(usernameField)
        } else {
            setGoodToGo(usernameField)
        }
        
        if usernameField.text?.characters.count > 18 {
            length = true
            setError(usernameField)
        }
        
        
        if usernameField.text?.characters.count < 6 {
            setError(usernameField)
            userNameRequirements.textColor = hexStringToUIColor("#f27163")
            userNameRequirements.text = "Username to short"
        }
        
        for c in usernameField.text!.characters {
            if c == " "{
                space = true
                setError(usernameField)
            }
        }
        
        userNameRequirements.textColor = textColor
        userNameRequirements.text = "6-18 Characters, No Spaces"
        
        if usernameField.text?.characters.count < 6 {
            setError(usernameField)
            userNameRequirements.textColor = hexStringToUIColor("#f27163")
            userNameRequirements.text = "Username to short"
        }
        
        
        if uExists {
            userNameRequirements.textColor = hexStringToUIColor("#f27163")
            userNameRequirements.text = "Username already exists"
        }
        
        if space {
            userNameRequirements.textColor = hexStringToUIColor("#f27163")
            userNameRequirements.text = "Contains spaces"
        }
        
        if length {
                userNameRequirements.textColor = hexStringToUIColor("#f27163")
                userNameRequirements.text = "Over 18 characters"
        
        }
        
        if usernameField.text == "" {
            userNameRequirements.textColor = hexStringToUIColor("#f27163")
            userNameRequirements.text = "Username empty"
        }
        
        
    }
    
    func emailFieldDidChange(textView: UITextView) {
        if isValidEmail(emailField.text!){
            setGoodToGo(emailField)
        } else {
            setError(emailField)
        }
    
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func passwordFieldDidChange(textView: UITextView) {
       
        var length : Bool = false
        var space : Bool = false
        
        if passwordField.text?.characters.count > 6 {
            setGoodToGo(passwordField)
        }
        if passwordField.text?.characters.count > 18 {
            length = true
            setError(passwordField)
        }
        
        
        if passwordField.text?.characters.count < 6 {
            textView.layer.borderColor = defaultColor.CGColor
        }
        
        
        
        for c in passwordField.text!.characters {
            if c == " "{
                space = true
                setError(passwordField)
            }
        }
        
        if passwordField.text?.characters.count < 6 {
            textView.layer.borderColor = defaultColor.CGColor
        }
        
        passwordRequirements.textColor = textColor
        passwordRequirements.text = "6-18 Characters, No Spaces"
        
        if space {
            passwordRequirements.textColor = hexStringToUIColor("#f27163")
            passwordRequirements.text = "Contains space"
        }
        
        if length {
            passwordRequirements.textColor = hexStringToUIColor("#f27163")
            passwordRequirements.text = "Over 18 characters"
            
        }
    }
    
    func confirmPasswordDidChange(textView: UITextView) {
        if confirmPasswordField.text != passwordField.text{
            setError(confirmPasswordField)
            confirmPasswordLabel.textColor = hexStringToUIColor("#f27163")
            confirmPasswordLabel.text = "Passwords don't match"
        } else {
            setGoodToGo(confirmPasswordField)
            confirmPasswordLabel.text = ""
        }
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
        if textField == usernameField {
            if usernameField.text == "" {
                userNameRequirements.textColor = hexStringToUIColor("#f27163")
                userNameRequirements.text = "Username empty"
            }
        }
        
        if textField == passwordField {
            if passwordField.text?.characters.count < 6 {
                setError(passwordField)
                passwordRequirements.textColor = hexStringToUIColor("#f27163")
                passwordRequirements.text = "Password is to short"
            }
            if passwordField.text == "" {
                passwordRequirements.textColor = hexStringToUIColor("#f27163")
                passwordRequirements.text = "Password empty"
            }
        }

        
        UIApplication.sharedApplication().statusBarHidden = false
        if (textField == confirmPasswordField){
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIApplication.sharedApplication().statusBarHidden = true
        scrollView.setContentOffset(CGPointMake(0,160), animated: true)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        view.endEditing(true)
    }
    
    func getUsers(){
        DataService.dataService.USER_REF.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.usernameExists = false
                for snap in snapshots {
                    let test = snap.value.objectForKey("username") as! String
                    self.users.append(test.lowercaseString)
                }
            }
        })
    }
    
    //Complete Registration
    func registerClicked(){
        dismissKeyboard()
        errorMessage = ""
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
            if username != "" && email != "" && password != "" && confirmPassword != "" {
                if (confirmPassword == password){
                self.presentViewController(alertController, animated: true, completion: nil)
                
                    DataService.dataService.USER_REF.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            self.usernameExists = false
                            for snap in snapshots {
                                let test = snap.value.objectForKey("username") as! String
                                if (test == self.usernameField.text){
                                    self.usernameExists = true
                                }
                            }
                            
                            if (!self.usernameExists) {
                                // Set Email and Password for the New User.
                                DataService.dataService.BASE_REF.createUser(email, password: password, withValueCompletionBlock: { error, result in
                                    if error != nil {
                                        
                                        if let errorCode = FAuthenticationError(rawValue: error.code) {
                                            switch (errorCode) {
                                            case .EmailTaken:
                                                self.errorMessage = "email"
                                                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                                                self.signupErrorAlert("Oops!", message: "An account with this email address already exists")
                                            case .InvalidEmail:
                                                self.errorMessage = "email"
                                                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                                                self.signupErrorAlert("Oops!", message: "Please enter a valid email address")
                                            default:
                                                print("Handle default situation")
                                            }
                                        }
                                    } else {
                                        DataService.dataService.BASE_REF.authUser(email, password: password, withCompletionBlock: {
                                            err, authData in
                                            let user = ["provider": authData.provider!, "email": email!, "username": username!, "profileImage" : base64String, "rating" : "5.0"]
                                            // Send Data to DataService.swift
                                            DataService.dataService.createNewAccount(authData.uid, user: user)
                                            
                                            //Saving User uid to User Defaults
                                            NSUserDefaults.standardUserDefaults().setValue(result ["uid"], forKey: "uid")
                                            
                                            //Opens Main Feed
                                            self.alertController.dismissViewControllerAnimated(true, completion: nil)
                                            self.performSegueWithIdentifier("registerSegue", sender: nil)
                                        })
                                    }
                                })
                                
                                
                            } else {
                                self.errorMessage = "username"
                                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                                self.signupErrorAlert("Oops!", message: "This username already exists")
                            }
                            
                        }
                        
                    })
                    

            
                
            } else {
                //Shows Passwords don't match allert
                self.errorMessage = "passwords"
                signupErrorAlert("Oops", message: "Passwords Don't Match")

            }
        } else {
            //Shows Alert
            self.errorMessage = "missing"
            signupErrorAlert("Oops!", message: "Please fill in all fields")
        }
        
    }
    
    //Alert
    func signupErrorAlert(title: String, message: String) {
        let alertView = JSSAlertView().show(self, title: title, text: message)
        alertView.addAction(MakeFirstResponder)
    }
    
    func MakeFirstResponder(){
        if (errorMessage == "username"){
            setError(usernameField)
            usernameField.becomeFirstResponder()
        }
        if errorMessage == "email"{
            setError(emailField)
            emailField.becomeFirstResponder()
        }
        if errorMessage == "passwords"{
            setError(passwordField)
            setError(confirmPasswordField)
            passwordField.becomeFirstResponder()
        }
        if errorMessage == "missing"{
            if confirmPasswordField.text == "" {
                setError(confirmPasswordField)
                confirmPasswordField.becomeFirstResponder()
            }
            
            if passwordField.text == "" {
                setError(passwordField)
                passwordField.becomeFirstResponder()
            }
            
            if emailField.text == "" {
                setError(emailField)
                emailField.becomeFirstResponder()
            }
            
            if usernameField.text == "" {
                setError(usernameField)
                usernameField.becomeFirstResponder()
            }
            
        }
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

