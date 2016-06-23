//
//  RecentFeedback.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class RecentFeedback: UIViewController {
    var previousSegue : String = String()
    var username : String = String()
    
    
    @IBOutlet weak var currentUserLabel: UILabel!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButton(sender: UIButton) {
        if previousSegue == "Profile"{
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
            performSegueWithIdentifier("backToUsersProfile", sender: self)
        }
    }
    
    
    //Back to Chat Action
    @IBAction func backToFeedback(segue: UIStoryboardSegue){}
    
    //Table View
    @IBOutlet weak var tabletView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        currentUserLabel.text = username
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
        let cell : UsersRecentFeedBackCell = tableView.dequeueReusableCellWithIdentifier("RecentFeedbackCell")! as! UsersRecentFeedBackCell
        
        cell.tableConfig(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }
}
