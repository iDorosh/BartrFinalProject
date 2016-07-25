//
//  ChangePassword.swift
//  Bartr
//
//  Created by Ian Dorosh on 7/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import FirebaseAuth
import SCLAlertView

class ChangePassword: UIViewController, UITextFieldDelegate {
    
     @IBOutlet weak var currentPassword: UITextField!
     @IBOutlet weak var newPassword: UITextField!
     @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var done: UIButton!
    
    var length : Bool = false
    var short : Bool = false
    var space : Bool = false
    var empty : Bool = false
    var validPassword : Bool = false
    var passwordsMatch : Bool = false
    var alertController = UIAlertController()
    
    
    
    @IBAction func done(sender: UIButton) {
        self.view.endEditing(true)
        checkFields()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        done.hidden = true
        
        currentPassword.delegate = self
        newPassword.delegate = self
        confirmPassword.delegate = self
        alertController = showLoading("Saving Changes...")
        
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        done.hidden = false
    }
    
    func checkFields(){
        validPassword = false
        passwordsMatch = false
       
        length  = false
        short  = false
        space  = false
        empty  = false
        
        for c in newPassword.text!.characters {
            if c == " "{
                space = true
            }
        }
        
        let trimmedString = currentPassword.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let trimmedString2 = newPassword.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let trimmedString3 = confirmPassword.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if  trimmedString == ""  {
            emptyFields("Current password is missing")
        } else if trimmedString2 == ""{
            emptyFields("New password is missing")
        } else if trimmedString3 == ""{
            emptyFields("Confirm password is missing")
        }else if newPassword.text?.characters.count > 18 {
            length = true
            toLong()
            
        } else if newPassword.text?.characters.count <= 6 && newPassword.text != ""{
            short = true
            toShort()
        } else if space{
            space = true
            containsSpace()
        } else {
            if confirmPassword.text == newPassword.text {
                changePassword()
            }else {
                passwordMatch()
            }
        }
    }
    /*
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
     
     
     return confirmationString
     }

     */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changePassword(){
    
        self.presentViewController(alertController, animated: true, completion: nil)
        var credential: FIRAuthCredential
        
        let user = FIRAuth.auth()?.currentUser
        credential = FIREmailPasswordAuthProvider.credentialWithEmail((FIRAuth.auth()?.currentUser?.email)!, password: currentPassword.text!)

        
        user?.reauthenticateWithCredential(credential) { error in
            if error != nil {
                self.incorrectPassword()
            } else {
            FIRAuth.auth()?.currentUser?.updatePassword(self.newPassword.text!, completion: { (error) in
                if error != nil {
                    self.alertController.dismissViewControllerAnimated(true, completion: nil)
                    self.fail()
                } else {
                    self.alertController.dismissViewControllerAnimated(true, completion: nil)
                    
                    var newCredential: FIRAuthCredential
                    newCredential = FIREmailPasswordAuthProvider.credentialWithEmail((FIRAuth.auth()?.currentUser?.email)!, password: self.newPassword.text!)
                     user?.reauthenticateWithCredential(newCredential, completion: nil)
                    self.view.endEditing(true)
                    self.success()
                }
                
            })
        }
      }
    }
    
        func incorrectPassword(){
            alertController.dismissViewControllerAnimated(true, completion: nil)
            let alertView = SCLAlertView()
        
            alertView.addButton("Ok"){
                self.currentPassword.becomeFirstResponder()
                alertView.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alertView.showCloseButton = false
            
            alertView.showWarning("Error", subTitle: "Current Password is incorrect")
        }

    
    func passwordUpdated(){
        let alertView = SCLAlertView()
        alertView.addButton("Done"){alertView.dismissViewControllerAnimated(true, completion: nil)}
        
        alertView.showCloseButton = false
        
        alertView.showSuccess("Success", subTitle: "Your profile has been updated")
    }
    
        
        func fail(){
            alertController.dismissViewControllerAnimated(true, completion: nil)
            let alertView = SCLAlertView()
            alertView.addButton("Done"){
                alertView.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alertView.showCloseButton = false
            
            alertView.showWarning("Error", subTitle: "Something went wrong")
        }
    
    func success(){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Done"){
            alertView.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("BackToEdit", sender: self)}
        alertView.showCloseButton = false
        self.view.endEditing(true)
        alertView.showSuccess("Update", subTitle: "Password update successful")
    }
    
    func toLong(){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Ok"){
            self.newPassword.becomeFirstResponder()
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        
        alertView.showWarning("Error", subTitle: "New password is to long")
    }
    
    func toShort(){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Ok"){
            self.newPassword.becomeFirstResponder()
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        
        alertView.showWarning("Error", subTitle: "New password is to short")
    }
    
    func containsSpace(){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Ok"){
            self.newPassword.becomeFirstResponder()
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        
        alertView.showWarning("Error", subTitle: "New password contains spaces")
    }
    
    func passwordMatch(){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Ok"){
            self.confirmPassword.becomeFirstResponder()
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        
        alertView.showWarning("Error", subTitle: "passwords don't match")
    }
    
    func emptyFields(subTitle : String){
        alertController.dismissViewControllerAnimated(true, completion: nil)
        let alertView = SCLAlertView()
        alertView.addButton("Ok"){
            if subTitle == "Current password is missing"{
                self.currentPassword.becomeFirstResponder()
            } else if subTitle == "New password is missing" {
                self.newPassword.becomeFirstResponder()
            } else {
                self.confirmPassword.becomeFirstResponder()
            }
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        
        alertView.showWarning("Error", subTitle: subTitle)
    }
}
