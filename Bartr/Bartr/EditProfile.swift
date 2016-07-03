//
//  EditProfile.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/19/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class EditProfile: UIViewController {
    @IBAction func backToEditProfile(segue: UIStoryboardSegue){}
    
    var croppingEnabled: Bool = true
    var libraryEnabled: Bool = true
    var newImage : UIImage = UIImage()
    var base64String : String = String()
    var imagePicked : Bool = false
    var currentEmail : String = ""
    var currentPasswordString : String = ""
    
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
        currentEmail = email.placeholder!
        getUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Fill in current users info
    func getUserData() -> Void {
        DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            
            currentUserUID = snapshot.key
            self.currentUser = snapshot.value.objectForKey("username") as! String
            //let currentEmail = snapshot.value.objectForKey("email") as! String
            let currentProfileImg = snapshot.value.objectForKey("profileImage") as! String
            
            let userEmail : String = snapshot.value.objectForKey("email") as! String
            
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
        var updatePost : Bool = false
        encodePhoto(userProfileImg.image!)
        let selectedPostRef = DataService.dataService.USER_REF.childByAppendingPath(currentUserUID)
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
        }
        
        if self.email.text != "" {
            updateEmail(self.email.text!, currentPassword: "password")
        }
        
        if updatePost{
            updatePosts()
        }
    }
    
    func updatePosts(){
        DataService.dataService.POST_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value.objectForKey("postUID") as! String
                    if (test == currentUserUID){
                        let selectedPostRef = DataService.dataService.POST_REF.childByAppendingPath(snap.key)
                        
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
        DataService.dataService.BASE_REF.childByAppendingPath("Recent").observeEventType(FEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value.objectForKey("withUserUserId") as! String
                    if (test == currentUserUID){
                        let selectedPostRef = DataService.dataService.BASE_REF.childByAppendingPath("Recent/\(snap.key)")
                        
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
            self.emptyFields()
            
        })
    }
    
    
    func emptyFields(){
        email.text = ""
        userName.text = ""
        currentPassword.text = ""
        newPassword.text = ""
        confirmPassword.text = ""
        view.endEditing(true)
        
    }
    
    func updateEmail(newEmail : String, currentPassword: String) -> String {
        let ref = Firebase(url: BASE_URL);
        var confirmationString : String = ""
        
        ref.changeEmailForUser(currentEmail, password: currentPassword, toNewEmail: newEmail) { error in
            if error != nil {
                confirmationString = "\(error.code.description)"
            } else {
                confirmationString = "Success"
            }

        }
        return confirmationString
    }
    
    func changePassword() -> String{
        var confirmationString : String = ""
            let ref = Firebase(url: BASE_URL)
            ref.changePasswordForUser(email.placeholder, fromOld: currentPassword.text, toNew: newPassword.text , withCompletionBlock: { error in
                    if error != nil {
                        confirmationString = "\(error.code.description)"
                    } else {
                        confirmationString = "Success"
                    }
                self.emptyFields()
        })
        
        return confirmationString
    }
    
    //Encode listing image to send as a string to Firebase
    func encodePhoto(image: UIImage){
        var data: NSData = NSData()
        data = UIImageJPEGRepresentation(image,0.5)!
        base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    
    

    /*
    let ref = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com")
    ref.changePasswordForUser("bobtony@example.com", fromOld: "correcthorsebatterystaple",
    toNew: "batteryhorsestaplecorrect", withCompletionBlock: { error in
    if error != nil {
    // There was an error processing the request
    } else {
    // Password changed successfully
    }
    })
 */
}
