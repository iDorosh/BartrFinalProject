//
//  ChatViewController.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SCLAlertView

class Chat: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
//Variables
    //Data
    var recents : [NSDictionary] = []
    var refresh : NSTimer = NSTimer()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Strings
    var currentUser : String = ""
    var senderUID : String = ""
    var chatRoomID : String = ""
    var selectedUID : String = ""
    var selectedUsename : String = ""
    var profileImage = String()
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Outlers
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var noMessages: UILabel!
    @IBOutlet weak var tabletView: UITableView!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    
//Actions
    @IBAction func backToChat(segue: UIStoryboardSegue){}
    @IBAction func signinButton(sender: UIButton) {
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

//Load UI
    override func viewWillDisappear(animated: Bool) { refresh.invalidate() }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewWillLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        setUpViewWillAppear()
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Functions
    //Setup UI
        //ViewWillApear
            func setUpViewWillAppear(){
                refresh = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector (timedUpdate), userInfo: nil, repeats: true)
                if (!signUpSkipped){
                    refresh.fire()
                }
                self.navigationController?.navigationBarHidden = true
                self.tabBarController?.tabBar.hidden = false
            }
        
            //ViewWillLoad
            func setUpViewWillLoad(){
                if !signUpSkipped {
                    self.navigationController?.navigationBarHidden = true
                    self.tabBarController?.tabBar.hidden = false
                    senderUID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
                    DataService.dataService.CURRENT_USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
                        self.currentUser = snapshot.value!.objectForKey("username") as! String
                        
                    })
                    self.updateTableView()
                    UIApplication.sharedApplication().statusBarStyle = .Default
                    
                } else {
                    signinView.hidden = false
                    self.navigationController?.navigationBarHidden = true
                    self.tabBarController?.tabBar.hidden = false
                }
            }

            //Get current users uid
            func getUID(){
                DataService.dataService.USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        
                        for snap in snapshots {
                            let test = snap.value!.objectForKey("username") as! String
                            if (test == self.currentUser){
                                self.senderUID = snap.key
                            }
                        }
                    }
                    
                })
            }
    
    
        //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
        //Set Up Table View
            //Number of rows in table
            func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if recents.count > 0 {
                    noMessages.hidden = true
                } else {
                    noMessages.hidden = false
                }
                return recents.count
            }
    
            //Return recent cell
            func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
                let cell : CustomChatTableCell = tableView.dequeueReusableCellWithIdentifier("chatCell")! as! CustomChatTableCell
                let recent = recents[indexPath.row]
                cell.tableConfig(recent)
                return cell
            }
    
            //Pass data to chat view controller
            func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
                let recent = recents[indexPath.row]
                profileImage = (recent.objectForKey("usersProfileImage") as? String)!
                for userId in recent["members"] as! [String] {
                    
                    if userId != NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String {
                        chatRoomID = (recent["chatRoomId"] as! String)
                        selectedUsename = (recent["withUserUsername"] as! String)
                        selectedUID = (recent["withUserUserId"] as! String)
                    }
                    
                }
                checkforBlock(selectedUID, recent: recent)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
    
            //Check if current user is block
    func checkforBlock(uid : String, recent : NSDictionary) {
                DataService.dataService.USER_REF.child(uid).child("blockedUsers").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        if snapshots.count > 0 {
                            for snap in snapshots{
                                
                                
                                if (snap.value as? Dictionary<String, AnyObject>) != nil {
                                    let key = snap.key
                                    if key == FIRAuth.auth()?.currentUser!.uid {
                                        self.blocked()
                                    } else {
                                        //Restarts chat if needed
                                        RestartRecentChat(recent)
                                        self.performSegueWithIdentifier("GoToThread", sender: self)
                                        
                                    }
                                }
                            }
                        }else {
                            
                            //Restarts chat if needed
                            RestartRecentChat(recent)
                            self.performSegueWithIdentifier("GoToThread", sender: self)
                        }
                    }
                })
                
            }

    
            func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                return true
                
            }
    
            //Delete recents
            func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                let recent = recents[indexPath.row]
                
                recents.removeAtIndex(indexPath.row)
                
                DeleteRecentItem(recent)
                
                tableView.reloadData()
            }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
        //Prepare for segue
    
        //Pass data to message view
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
          
            super.prepareForSegue(segue, sender: sender)
            let chatVc : ChatViewController = segue.destinationViewController as! ChatViewController
            chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
            chatVc.senderDisplayName = ""
            chatVc.recieverUsername = selectedUsename
            chatVc.chatRoomID = chatRoomID
            chatVc.previous = "TBLV"
            chatVc.selectedImage = profileImage
            chatVc.recieverUID = selectedUID
           
        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Get Recents on initial load
    
        func updateTableView(){
            ref.child("Recent").queryOrderedByChild("userId").queryEqualToValue(senderUID).observeEventType(.Value, withBlock: {
                snapshot in
                    self.recents.removeAll()
                
                if snapshot.exists() {
                    let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key : "date", ascending: false)])
                    
                    for recent in sorted {
                        self.recents.append(recent as! NSDictionary)
                    }
                }
                if self.recents.isEmpty {
                    self.tabletView.hidden = true
                } else {
                   self.tabletView.hidden = false
                }
                self.tabletView.reloadData()
            })
        }
        
        //Update recieved time
        func timedUpdate(){
            ref.child("Recent").queryOrderedByChild("userId").queryEqualToValue(senderUID).observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                self.recents.removeAll()
                
                if snapshot.exists() {
                    let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key : "date", ascending: false)])
                    
                    for recent in sorted {
                        self.recents.append(recent as! NSDictionary)
                    }
                }
                if self.recents.isEmpty {
                    self.tabletView.hidden = true
                } else {
                    self.tabletView.hidden = false
                }
                self.tabletView.reloadData()
            })
        }
    
    
        //Blocked alert
        func blocked(){
            let alertView = SCLAlertView()
            alertView.addButton("OK"){}
            alertView.showCloseButton = false
            alertView.showWarning("Blocked", subTitle: "You have been blocked from this thread")
        }

//-----------------------------------------------------------------------------------------------------------------------------------------------------//

}
