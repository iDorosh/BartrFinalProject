//
//  EmailUsernamePassword.swift
//  Bartr
//
//  Created by Ian Dorosh on 7/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import ALCameraViewController
import SCLAlertView
import FirebaseDatabase
import FirebaseAuth

class EmailUsernamePassword: UIViewController, UITextFieldDelegate {
    
    
//Variables
    //Data
    var alertController = UIAlertController()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Data
    var users : [String] = []
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Strings
    var currentUser : String = String()
    var base64String : String = String()
    var currentEmail : String = ""
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //UIImage
    var newImage : UIImage = UIImage()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Boolean
    var croppingEnabled: Bool = true
    var libraryEnabled: Bool = true
    var usernameExists = false
    var updatePost : Bool = false
    var uExists : Bool = false
    var length : Bool = false
    var short : Bool = false
    var space : Bool = false
    var empty : Bool = false
    var emailEmpty : Bool = false
    var invalidEmail : Bool = false
    var updateCurrentEmail : Bool = false
    var imagePicked : Bool = false
    var usernameChanged : Bool = false
    var emailChanged : Bool = false
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //UIColor
    var defaultColor = UIColor()
    var textColor = UIColor()
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

//Outlets
    @IBOutlet weak var done: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

//Actions
    
    @IBOutlet weak var cancel: UIButton!
    
    @IBAction func doneButton(sender: UIButton) {
        self.view.endEditing(true)
        checkForChanges()
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        if imagePicked || usernameChanged || emailChanged {
            discard()
        } else {
            self.performSegueWithIdentifier("BackToEdit", sender: self)
        }
        
    }
    
    @IBAction func editProfileButton(sender: UIButton) {
        openCamera()
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//UI
    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        getUserData()
        usernameField.delegate = self
        emailField.delegate = self
        defaultColor = usernameField.backgroundColor!
        textColor = usernameField.textColor!
        alertController = showLoading("Saving Changes...")
    }

//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Functions
    //Keyboards
        //If fields changed
        func textFieldDidBeginEditing(textField: UITextField) {
            if textField === usernameField{
                usernameChanged = true
                done.hidden = false
            } else {
                emailChanged = true
                done.hidden = false
            }
        }
        
        func checkForChanges(){
            if usernameChanged {
                
                    uExists  = false
                    length  = false
                    short  = false
                    space  = false
                    empty  = false
                
                    //Username contains space
                    for c in usernameField.text!.characters {
                        if c == " "{
                            space = true
                        }
                    }
                
                    //Username is empty
                    let trimmedString = usernameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    if  trimmedString == ""  {
                        empty = true
                        fail("Username Error", subtitle: "Username is empty")
                    //Username taken
                    } else if users.contains(usernameField.text!.lowercaseString){
                        uExists = true
                        fail("Username Error", subtitle: "Username is taken")
                    //Username to long
                    } else if usernameField.text?.characters.count > 18 {
                        length = true
                        fail("Username Error", subtitle: "Username is to long")
                    //Username to short
                    } else if usernameField.text?.characters.count < 6 && usernameField.text != ""{
                        short = true
                        fail("Username Error", subtitle: "Username is to short")
                    //Username contains space
                    } else if space{
                        space = true
                        fail("Username Error", subtitle: "Username contains space")
                    } else {
                        if emailChanged {
                            checkEmail()
                        } else {
                            updateFirebase()
                        }
                    }
            } else if emailChanged {
                checkEmail()
            } else {
                if imagePicked {
                    if emailChanged {
                        checkEmail()
                    } else {
                        updateFirebase()
                    }
                }
            }
        }
    
        //Check email is valid with no spaces
        func checkEmail(){
            emailEmpty = false
            invalidEmail = false
            updateCurrentEmail = false
            let trimmedString = emailField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if trimmedString == "" {
                emailEmpty = true
                fail("Email Error", subtitle: "Email is empty")
            } else if !isValidEmail(emailField.text!){
                invalidEmail = true
                fail("Email Error", subtitle: "Email is invalid")
            } else {
                updateCurrentEmail = true
                updateFirebase()
            }
            

        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Firebase
        //Fill in current data
        func getUserData() -> Void {
            DataService.dataService.CURRENT_USER_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                
                currentUserUID = snapshot.key
                self.currentUser = snapshot.value!.objectForKey("username") as! String
                //let currentEmail = snapshot.value.objectForKey("email") as! String
                let currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
                
                let userEmail : String = snapshot.value!.objectForKey("email") as! String
                self.currentEmail = userEmail
                let decodedData = NSData(base64EncodedString: currentProfileImg, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                
                let decodedimage = UIImage(data: decodedData!)
                
                self.profileImage.image = decodedimage! as UIImage
                self.emailField.text = FIRAuth.auth()?.currentUser?.email
                self.usernameField.text = self.currentUser
            })
        }
    
        //Update username or password if needed then update email if needed
        func updateFirebase(){
            if usernameChanged || imagePicked {
                self.view.endEditing(true)
                self.presentViewController(alertController, animated: true, completion: nil)
                let selectedPostRef = DataService.dataService.USER_REF.child(currentUserUID)
                if usernameChanged {
                selectedPostRef.updateChildValues([
                        "username" : self.usernameField.text!,
                        ], withCompletionBlock: {_,_ in 
                    })
                }
                if self.imagePicked {
                    selectedPostRef.updateChildValues([
                        "profileImage" : encodePhoto(self.profileImage.image!),
                        ], withCompletionBlock: {_,_ in
                            self.updatePosts()
                    })
                } else {
                    self.updatePosts()
                }

            } else {
                updateEmail(emailField.text!)
            }
            
        }
        
        //Update post profile images
        func updatePosts(){
            DataService.dataService.POST_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    if snapshot.exists() {
                        for snap in snapshots {
                            let test = snap.value!.objectForKey("postUID") as! String
                            if (test == FIRAuth.auth()?.currentUser?.uid){
                                let selectedPostRef = DataService.dataService.POST_REF.child(snap.key)
                                    selectedPostRef.updateChildValues([
                                        "author" : self.usernameField.text!,
                                        ])
                                
                                    if self.imagePicked {
                                        let selectedPostRef2 = DataService.dataService.POST_REF.child(snap.key)
                                        selectedPostRef2.updateChildValues([
                                            "userProfileImg" : encodePhoto(self.profileImage.image!),
                                            ])
                                    }
                            }
                        }
                    }
                }
                self.updateRecent()
            })
            
        }
        
        //Update message images
        func updateRecent(){
            DataService.dataService.BASE_REF.child("Recent").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    if snapshot.exists() {
                        //Run through existing recent threads and update the images and usernames
                        for snap in snapshots {
                            let test = snap.value!.objectForKey("withUserUserId") as! String
                            if (test == currentUserUID){
                                let selectedPostRef = DataService.dataService.BASE_REF.child("Recent/\(snap.key)")
                                
                                
                                selectedPostRef.updateChildValues([
                                        "username" : self.usernameField.text!,
                                        ], withCompletionBlock: {_,_ in
                                    })
                                
                                if self.imagePicked {
                                    selectedPostRef.updateChildValues([
                                        "usersProfileImage" : encodePhoto(self.profileImage.image!),
                                        ], withCompletionBlock: {_,_ in
                                    })
                                }
                            }
                        
                        }
                    }
                    
                }
                //Update email if needed
                if self.updateCurrentEmail {
                    self.updateEmail(self.emailField.text!)
                } else {
                    self.complete()
                }
            })
        }

    
        //Update email password confrimation
        func updateEmail(newEmail : String){
            alertController.dismissViewControllerAnimated(true, completion: nil)
            let alert = SCLAlertView()
            alert.showCloseButton = false
            let txt = alert.addTextField("Password Required")
            alert.addButton("Continue") {
                self.pushNewEmail(newEmail, password: txt.text!)
            }
            alert.addButton("Cancel"){
                self.emailField.text = FIRAuth.auth()?.currentUser?.email
                alert.dismissViewControllerAnimated(true, completion: nil)}
            alert.showEdit("Reset Email", subTitle: "Please enter your password to change your email")
        }
        
        func pushNewEmail (newEmail : String, password : String){
            
            //Present alert updating data
            if !usernameChanged && !imagePicked {
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            //Create user credential for reauthentication
            let user = FIRAuth.auth()?.currentUser
            var credential: FIRAuthCredential
            
            credential = FIREmailPasswordAuthProvider.credentialWithEmail((FIRAuth.auth()?.currentUser?.email)!, password: password)
            
            
            // Prompt the user to re-provide their sign-in credentials
            user?.reauthenticateWithCredential(credential) { error in
                if error != nil {
                    self.passwordWrong()
                } else {
                    FIRAuth.auth()?.currentUser?.updateEmail(newEmail, completion: { (error) in
                        if error != nil {
                            self.passwordWrong()
                        } else {
                            let selectedPostRef = DataService.dataService.USER_REF.child((FIRAuth.auth()?.currentUser?.uid)!)
                            selectedPostRef.updateChildValues([
                                "email" : self.emailField.text!,
                                ], withCompletionBlock: { (error, Firebase) in
                                    //Reauthenticate user to update information
                                    var newCredential: FIRAuthCredential
                                    newCredential = FIREmailPasswordAuthProvider.credentialWithEmail(newEmail, password: password)
                                    user?.reauthenticateWithCredential(newCredential, completion: nil)
                                    self.success()
                            })
                            
                        }
                       
                    })
                    
                }
            }

        }

        //Get users to check for existing usernames
        func getUsers(){
        DataService.dataService.USER_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    self.usernameExists = false
                    for snap in snapshots {
                        let test = snap.value!.objectForKey("username") as! String
                        if test != currentUsernameString {
                            self.users.append(test.lowercaseString)
                        }
                    }
                }
            })
        }

    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Camera
        //Opening custom CameraViewController
        func openCamera()
        {
            let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
                if (image != nil){
                    self!.profileImage.image = image
                    self!.imagePicked = true
                    self!.done.hidden = false
                }
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            presentViewController(cameraViewController, animated: true, completion: nil)
        }
        
        //Opeing Library
        func openLibrary(){
            let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
                self.profileImage.image = image
                self.imagePicked = true
                self.done.hidden = false
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            presentViewController(libraryViewController, animated: true, completion: nil)
        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Check for valid email
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Alerts
    func complete(){
        success()
    }
    
    //Successfully updated
    func success(){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Done"){
            alertView.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("BackToEdit", sender: self)}
        alertView.showCloseButton = false
        alertView.showSuccess("Update", subTitle: "Information update successful")
    }

    //Entered password is incorrect
    func passwordWrong(){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Retry"){
            self.updateEmail(self.emailField.text!)
        }
        alertView.addButton("Cancel"){
            self.emailField.text = FIRAuth.auth()?.currentUser?.email
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        alertView.showWarning("Error", subTitle: "Invalid Password")
    }

    //Failed update
    func fail(title : String, subtitle : String){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Done"){
            self.setResponder(title)
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        alertView.showWarning(title, subTitle: subtitle)
    }
    
    //Dicard changes
    func discard(){
        let alertView = SCLAlertView()
        alertView.addButton("Discard"){
            self.performSegueWithIdentifier("BackToEdit", sender: self)
        }
        alertView.addButton("Cancel"){
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        alertView.showWarning("Discard", subTitle: "Are you sure that you want to discard the changes")
    }
    
    
    //Switch
    func setResponder(title: String){
        switch title {
        case "Email Error":
            emailField.becomeFirstResponder()
        case "Username Error":
            usernameField.becomeFirstResponder()
        default:
            break
        }
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

}
