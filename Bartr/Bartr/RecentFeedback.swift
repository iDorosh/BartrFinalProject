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
    
    
//Variables
    //Data
    var feedBack = [FeedbackObject]()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Strings
    var previousSegue : String = String()
    var username : String = String()
    var uid : String = String()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //UIImages
    var profileImage : UIImage = UIImage()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Boolean
    var otherUser : Bool = false
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Outlets
    @IBOutlet weak var noFeedbackLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var feedbackCount: UILabel!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var UserProfilePicture: UIImageView!
    @IBOutlet weak var tabletView: UITableView!
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Actions
    @IBAction func backButton(sender: UIButton) {
        if previousSegue == "Profile"{
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
            performSegueWithIdentifier("backToUsersProfile", sender: self)
        }
    }
    
    //Back to Chat Action
    @IBAction func backToFeedback(segue: UIStoryboardSegue){}
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//UI
    
    override func viewWillAppear(animated: Bool) { self.tabBarController?.tabBar.hidden = false }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        currentUserLabel.text = username
        UserProfilePicture.image = profileImage
        updateFeedback()
        getFeedback()
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Functions
    //Table View
        //Set Up Table View
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if feedBack.count == 0 {
                tableView.hidden = true
                noFeedbackLabel.hidden = false
            } else {
                tableView.hidden = false
                noFeedbackLabel.hidden = true
            }
            return feedBack.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            let currentFeedback = feedBack[indexPath.row]
            let cell : UsersRecentFeedBackCell = tableView.dequeueReusableCellWithIdentifier("RecentFeedbackCell")! as! UsersRecentFeedBackCell
            
            cell.tableConfig(currentFeedback)
            return cell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
            
        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Firebase
        //Get user rating
        func updateFeedback(){
            DataService.dataService.USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    
                    for snap in snapshots {
                        if (snap.key == self.uid){
                            self.floatRatingView.rating = Float(snap.value!.objectForKey("rating") as! String)!
                            self.ratingLabel.text = "\(round((Float(snap.value!.objectForKey("rating") as! String)!)*10)/10) Star Rating"
                        }
                    }
                }
            })
        }
        
        //Get user feedback
        func getFeedback(){
            if otherUser {
                DataService.dataService.BASE_REF.child("users").child(uid).child("feedback").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    self.feedBack = []
                    
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        
                        //Get feedback for user with uid
                        for snap in snapshots {
                            
                            //Append to feedback
                            if let feedbackDictionary = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = FeedbackObject(key: key, dictionary: feedbackDictionary)
                                self.feedBack.insert(post, atIndex: 0)
                                
                            }
                        }
                        
                    }
                    
                    //Set rating label
                    if self.feedBack.count > 1 {
                        self.feedbackCount.text = "\(self.feedBack.count) ratings"
                    } else if self.feedBack.count == 0{
                        self.feedbackCount.text = "No ratings"
                    }else {
                        self.feedbackCount.text = "\(self.feedBack.count) rating"
                    }
                    
                    self.tableView.reloadData()
                })
                
            } else {
                
                DataService.dataService.CURRENT_USER_REF.child("feedback").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    self.feedBack = []
                    
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        //Get feedback for current user
                        for snap in snapshots {
                            
                            if let feedbackDictionary = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = FeedbackObject(key: key, dictionary: feedbackDictionary)
                                self.feedBack.insert(post, atIndex: 0)
                                
                            }
                        }
                        
                    }
                    
                    //Set rating label
                    if self.feedBack.count > 1 {
                        self.feedbackCount.text = "\(self.feedBack.count) ratings"
                    } else {
                        self.feedbackCount.text = "\(self.feedBack.count) rating"
                    }
                    
                    self.tableView.reloadData()
                })
            }
        }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

}
