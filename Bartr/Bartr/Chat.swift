//
//  ChatViewController.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class Chat: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    var recents : [NSDictionary] = []
    
    var currentUser : String = ""
    var senderUID : String = ""
    var chatRoomID : String = ""
    
    var selectedUsename : String = ""
    
    
    //Back to Chat Action
    @IBAction func backToChat(segue: UIStoryboardSegue){}
    
    //Table View
    @IBOutlet weak var tabletView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderUID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        
            DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
                self.currentUser = snapshot.value.objectForKey("username") as! String
                
            })
    
        
        self.updateTableView()
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        getUserInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getUID(){
        DataService.dataService.USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value.objectForKey("username") as! String
                    if (test == self.currentUser){
                        self.senderUID = snap.key
                    }
                }
            }
            
        })

    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell : CustomChatTableCell = tableView.dequeueReusableCellWithIdentifier("chatCell")! as! CustomChatTableCell
        let recent = recents[indexPath.row]
        cell.tableConfig(recent)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let recent = recents[indexPath.row]
        for userId in recent["members"] as! [String] {
            
            if userId != NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String {
                chatRoomID = (recent["chatRoomId"] as! String)
                selectedUsename = (recent["withUserUsername"] as! String)
            }
            
        }
        
        RestartRecentChat(recent)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("GoToThread", sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let recent = recents[indexPath.row]
        
        recents.removeAtIndex(indexPath.row)
        
        DeleteRecentItem(recent)
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        super.prepareForSegue(segue, sender: sender)
        let chatVc : ChatViewController = segue.destinationViewController as! ChatViewController
        chatVc.senderId = DataService.dataService.USER_REF.authData.uid
        chatVc.senderDisplayName = ""
        chatVc.recieverUsername = selectedUsename
        chatVc.chatRoomID = chatRoomID
        chatVc.previous = "TBLV"
       
    }
    
    func updateTableView(){
        let ref = Firebase(url: BASE_URL)
        
   
        ref.childByAppendingPath("Recent").queryOrderedByChild("userId").queryEqualToValue(senderUID).observeEventType(.Value, withBlock: {
            snapshot in
                self.recents.removeAll()
            
            if snapshot.exists() {
                let sorted = (snapshot.value.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key : "date", ascending: false)])
                
                for recent in sorted {
                    self.recents.append(recent as! NSDictionary)
                }
            }
            self.tabletView.reloadData()
        })
    }
    

}
