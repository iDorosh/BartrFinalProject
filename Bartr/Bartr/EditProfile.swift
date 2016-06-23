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
    
    //Variables
    var currentUser : String = String()
    
    //Outlets
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Fill in current users info
    func getUserData() -> Void {
        DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
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
