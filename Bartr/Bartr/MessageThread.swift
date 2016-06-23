//
//  MessageThread.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/17/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class MessageThread: UIViewController {
    
    var croppingEnabled: Bool = false
    var libraryEnabled: Bool = true

    //Block User Action
    @IBAction func BlockUser(sender: UIButton) {
        showAlert("Block User", text: "Are you sure that you want to block this user?", buttonText: "Block", cancelText: "Cancel", callBack: "Block")
    }
    
    @IBAction func addAtachment(sender: UIButton) {
        openCamera()
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
    
    func openCamera()
    {
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    func openLibrary(){
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(libraryViewController, animated: true, completion: nil)
    }

    
}
