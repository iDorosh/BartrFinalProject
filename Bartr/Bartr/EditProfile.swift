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
    
    var usernameExists = false
    
    var users : [String] = []
    
    var alertController = UIAlertController()
    
    var croppingEnabled: Bool = true
    var libraryEnabled: Bool = true
    var newImage : UIImage = UIImage()
    var base64String : String = String()
    var imagePicked : Bool = false
    var currentEmail : String = ""
    var currentPasswordString : String = ""
    
    var defaultColor = UIColor()
    var textColor = UIColor()
    
    @IBOutlet weak var usernameError: UILabel!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var currentPasswordError: UILabel!
    @IBOutlet weak var newPasswordError: UILabel!
    
    @IBOutlet weak var cofirmPasswordError: UILabel!
    
    
    //Variables
    var currentUser : String = String()
    
    //Outlets
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    
  
    @IBAction func saveButtonAction(sender: UIButton) {
        updateFirebase()
    }
    
    @IBAction func changeUserProfileImageButton(sender: UIButton) {
        openCamera()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertController = showLoading("Saving Changes...")
        getUsers()
        userName.delegate = self
        email.delegate = self
        currentPassword.delegate = self
        newPassword.delegate = self
        confirmPassword.delegate = self
        defaultColor = userName.backgroundColor!
        textColor = userName.textColor!
        
        userName.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        email.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        currentPassword.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        newPassword.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        confirmPassword.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        
        getUserData()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField === userName {
            usernameError.text = ""
            textField.layer.borderColor = defaultColor.CGColor
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField === email{
            if isValidEmail(email.text!){
                setGoodToGo(email)
            } else if textField === email && textField.text != "" {
                setError(email)
            }
        
        }
        if textField === userName {
            var uExists : Bool = false
            var length : Bool = false
            var space : Bool = false
            
            let trimmedString = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if textField === userName && trimmedString == ""  {
                textField.text = ""
            }
            
            if users.contains(userName.text!.lowercaseString){
                uExists = true
                usernameError.text = "username taken"
            } else {
                if userName.text != "" {
                usernameError.text = "ok!"
                }
            }
            
            if userName.text?.characters.count > 18 {
                length = true
                usernameError.text = "username long"
            }
            
            
            if userName.text?.characters.count < 6 && userName.text != ""{
                usernameError.text = "username short"
                //userNameRequirements.textColor = hexStringToUIColor("#f27163")
                //userNameRequirements.text = "Username to short"
            }
            
            for c in userName.text!.characters {
                if c == " "{
                    space = true
                    usernameError.text = "no spaces"
                }
            }
            
            //userNameRequirements.textColor = textColor
            //userNameRequirements.text = "6-18 Characters, No Spaces"
            
            if userName.text?.characters.count < 6 && userName.text != ""{
                usernameError.text = "username short"
                //userNameRequirements.textColor = hexStringToUIColor("#f27163")
                //userNameRequirements.text = "Username to short"
            }
            
            
            if uExists {
                //userNameRequirements.textColor = hexStringToUIColor("#f27163")
                //userNameRequirements.text = "Username already exists"
            }
            
            if space {
                //userNameRequirements.textColor = hexStringToUIColor("#f27163")
                //userNameRequirements.text = "Contains spaces"
            }
            
            if length {
                //userNameRequirements.textColor = hexStringToUIColor("#f27163")
                //userNameRequirements.text = "Over 18 characters"
                
            }
            
            if userName.text == "" {
                //userNameRequirements.textColor = hexStringToUIColor("#f27163")
                //userNameRequirements.text = "Username empty"
            }

        }
        
    }
    
    func textViewDidChange(textView: UITextView) {
        
    
        
        if textView === newPassword{
            var length : Bool = false
            var space : Bool = false
            
            if newPassword.text?.characters.count > 6 {
                setGoodToGo(newPassword)
            }
            if newPassword.text?.characters.count > 18 {
                length = true
                setError(newPassword)
            }
            
            
            if newPassword.text?.characters.count < 6 {
                textView.layer.borderColor = defaultColor.CGColor
            }
            
            
            
            for c in newPassword.text!.characters {
                if c == " "{
                    space = true
                    setError(newPassword)
                }
            }
            
            if newPassword.text?.characters.count < 6 {
                textView.layer.borderColor = defaultColor.CGColor
            }
            
            //newPassword.textColor = textColor
            //newPassword.text = "6-18 Characters, No Spaces"
            
            if space {
                //newPassword.textColor = hexStringToUIColor("#f27163")
                //newPassword.text = "Contains space"
            }
            
            if length {
                //passwordRequirements.textColor = hexStringToUIColor("#f27163")
                //passwordRequirements.text = "Over 18 characters"
                
            }

        }
        
        if textView === confirmPassword{
            if confirmPassword.text != newPassword.text{
                setError(confirmPassword)
                //confirmPasswordLabel.textColor = hexStringToUIColor("#f27163")
                //confirmPasswordLabel.text = "Passwords don't match"
            } else {
                setGoodToGo(confirmPassword)
                //confirmPasswordLabel.text = ""
            }

        }
    
    }
    
    func setError(textField : UITextField){
        textField.layer.borderColor = hexStringToUIColor("#f27163").CGColor
        textField.layer.cornerRadius = 2
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
    }
    
    func setGoodToGo(textField : UITextField){
        textField.layer.borderColor = defaultColor.CGColor
        textField.layer.cornerRadius = 2.0
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
    }


    func isValidEmail(testStr:String) -> Bool {
    
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Fill in current users info
    func getUserData() -> Void {
        DataService.dataService.CURRENT_USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            
            currentUserUID = snapshot.key
            self.currentUser = snapshot.value!.objectForKey("username") as! String
            //let currentEmail = snapshot.value.objectForKey("email") as! String
            let currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
            
            let userEmail : String = snapshot.value!.objectForKey("email") as! String
            self.currentEmail = userEmail
            let decodedData = NSData(base64EncodedString: currentProfileImg, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            
            let decodedimage = UIImage(data: decodedData!)
            
            self.userProfileImg.image = decodedimage! as UIImage
            self.email.placeholder = userEmail
            self.userName.placeholder = self.currentUser
        })
    }
    
    //Opening custom CameraViewController
    func openCamera()
    {
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            if (image != nil){
                self!.userProfileImg.image = image
                self!.imagePicked = true
            }
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    //Opeing Library
    func openLibrary(){
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            self.userProfileImg.image = image
            self.imagePicked = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    func updateFirebase(){
        self.view.endEditing(true)
        self.presentViewController(alertController, animated: true, completion: nil)
        var updatePost : Bool = false
        encodePhoto(userProfileImg.image!)
        let selectedPostRef = DataService.dataService.USER_REF.child(currentUserUID)
        if self.userName.text != "" {
            selectedPostRef.updateChildValues([
                "username" : self.userName.text!,
                ])
            updatePost = true
        }
        
        if self.imagePicked {
            selectedPostRef.updateChildValues([
                "profileImage": self.base64String,
                ])
            updatePost = true
        }
        
        if self.currentPassword.text != "" && self.newPassword.text != "" && self.confirmPassword.text != "" {
            changePassword()
        }
        
        
        
        if self.email.text != "" {
            enterPassword()
        }
 
        
        if updatePost{
            updatePosts()
        }
    }
    
    
    func updatePosts(){
        DataService.dataService.POST_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value!.objectForKey("postUID") as! String
                    if (test == currentUserUID){
                        let selectedPostRef = DataService.dataService.POST_REF.child(snap.key)
                        
                        if self.userName.text != "" {
                            selectedPostRef.updateChildValues([
                                "author": self.userName.text!,
                                ])
                        }
                        
                        if self.imagePicked {
                            selectedPostRef.updateChildValues([
                                "userProfileImg": self.base64String,
                                ])
                        }
                        
                    }
                }
            }
          
            self.updateRecent()
            
        })
        
    }
    
    func updateRecent(){
        DataService.dataService.BASE_REF.child("Recent").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value!.objectForKey("withUserUserId") as! String
                    if (test == currentUserUID){
                        let selectedPostRef = DataService.dataService.BASE_REF.child("Recent/\(snap.key)")
                        
                        if self.userName.text != "" {
                            selectedPostRef.updateChildValues([
                                "withUserUsername" : self.userName.text!,
                                ])
                        }
                        
                        if self.imagePicked {
                            selectedPostRef.updateChildValues([
                                "usersProfileImage": self.base64String,
                                ])
                        }
                        
                    }
                }
            }
            self.alertController.dismissViewControllerAnimated(true, completion: nil)
            self.success()
        })
    }
    
   
    func setFirstResponder(){
        performSegueWithIdentifier("backtoProfileSegue", sender: self)
    }
    

    func success(){
        let alertView = SCLAlertView()
        alertView.addButton("Done", target:self, selector:#selector(EditProfile.setFirstResponder))

        alertView.showCloseButton = false
        
        alertView.showSuccess("Success", subTitle: "Your profile has been updated")
    }
    
    func enterPassword(){
        self.alertController.dismissViewControllerAnimated(true, completion: nil)
        let alert = SCLAlertView()
        alert.showCloseButton = false
        let txt = alert.addTextField("Enter Password")
        alert.addButton("Change Email") {
            self.presentViewController(self.alertController, animated: true, completion: nil)
            self.updateEmail(self.email.text! , currentPassword: txt.text!)
        }
        alert.showEdit("Change Email", subTitle: "Please enter current password to change email")
    }

    
    
    
    func emptyFields(){
        email.text = ""
        userName.text = ""
        currentPassword.text = ""
        newPassword.text = ""
        confirmPassword.text = ""
        
        
    }
    
    func updateEmail(newEmail : String, currentPassword: String) -> String {
        var confirmationString : String = ""
        
        FIRAuth.auth()?.currentUser?.updateEmail(newEmail, completion: { (error) in
            if error != nil {
                confirmationString = "\(error)"
                self.alertController.dismissViewControllerAnimated(true, completion: nil)
                self.fail()
                print(confirmationString)
            } else {
                let selectedPostRef = DataService.dataService.USER_REF.child(currentUserUID)
                if self.email.text != "" {
                    selectedPostRef.updateChildValues([
                        "email" : self.email.text!,
                        ], withCompletionBlock: { (error, Firebase) in
                            self.alertController.dismissViewControllerAnimated(true, completion: nil)
                            self.success()
                    })
                }
            }

        })
        
       
        return confirmationString
    }
    
    func changePassword() -> String{
        var confirmationString : String = ""
            FIRAuth.auth()?.currentUser?.updatePassword(newPassword.text!, completion: { (error) in
                if error != nil {
                    confirmationString = "\(error!.code.description)"
                    self.alertController.dismissViewControllerAnimated(true, completion: nil)
                    self.fail()
                } else {
                    self.alertController.dismissViewControllerAnimated(true, completion: nil)
                    self.success()
                }

                })
        
        return confirmationString
    }
    
    //Encode listing image to send as a string to Firebase
    func encodePhoto(image: UIImage){
        var data: NSData = NSData()
        data = UIImageJPEGRepresentation(image,0.5)!
        base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    func getUsers(){
        DataService.dataService.USER_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.usernameExists = false
                for snap in snapshots {
                    let test = snap.value!.objectForKey("username") as! String
                    self.users.append(test.lowercaseString)
                }
            }
        })
    }

    
    func fail(){
        let alertView = SCLAlertView()
        alertView.addButton("Done", target:self, selector:#selector(EditProfile.setFirstResponder))
        
        alertView.showCloseButton = false
        
        alertView.showWarning("Error", subTitle: "Something went wrong")
    }
}
