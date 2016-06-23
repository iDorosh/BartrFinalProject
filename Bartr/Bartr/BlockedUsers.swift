//
//  BlockedUsers.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/22/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class BlockedUsers: UIViewController, UITableViewDataSource {

    //Back to Chat Action
    @IBAction func backToChat(segue: UIStoryboardSegue){}
    
    //Table View
    @IBOutlet weak var tabletView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let post = indexPath.row
        let cell : BlockedUsersTableCell = tableView.dequeueReusableCellWithIdentifier("blockCell")! as! BlockedUsersTableCell
        
        cell.tableConfig(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        showAlertView("Unblock User", text: "Are your sure that you want to unblock this user?", confirmButton: "Unblock", cancelButton: "Cancel")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //Alert to delete, mark as completed or rate
    func showAlertView(title: String?, text: String?, confirmButton: String?, cancelButton: String?){
        let alertview = JSSAlertView().show(
            self,
            title: title!,
            text: text!,
            buttonText: confirmButton!,
            cancelButtonText: cancelButton!
        )
        alertview.addAction(unBlockUser)
    }
    
    func unBlockUser(){
        self.performSegueWithIdentifier("backToEditProfileSegue", sender: self)
    }


}
