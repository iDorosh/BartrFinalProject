//
//  MessageThread.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/17/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class MessageThread: UIViewController {

    //Block User Action
    @IBAction func BlockUser(sender: UIButton) {
        showAlert("Block User", text: "Are you sure that you want to block this user?", buttonText: "Block", cancelText: "Cancel", callBack: "Block")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    //Show Alert to block the user
    func showAlert(title: String?, text: String?, buttonText: String?, cancelText: String?, callBack: String){
        let alertview = JSSAlertView().show(
            self,
            title: title!,
            text: text!,
            buttonText: buttonText!,
            cancelButtonText: cancelText!
        )
        
        switch callBack {
        case "Block":
            alertview.addAction(blockUser)
        default:
            break
        }
    }
    
    //Block user and goback a view controller
    func blockUser(){
        performSegueWithIdentifier("BlockUserSegue", sender: self)
    }

    
}
