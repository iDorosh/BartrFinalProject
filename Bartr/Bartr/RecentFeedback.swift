//
//  RecentFeedback.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class RecentFeedback: UIViewController {
    var previousSegue : String = String()
    var username : String = String()
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var currentUserLabel: UILabel!
    
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
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
        updateFeedback()
       
    }
    
    func updateFeedback(){
        DataService.dataService.USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value.objectForKey("username") as! String
                    if (test == self.username){
                        self.floatRatingView.rating = Float(snap.value.objectForKey("rating") as! String)!
                        self.ratingLabel.text = "\(snap.value.objectForKey("rating") as! String) Star Rating"
                    }
                }
            }
            
        })
        
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
