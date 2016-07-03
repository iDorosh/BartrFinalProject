//
//  Profile.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class Profile: UIViewController, UITableViewDataSource, FloatRatingViewDelegate {
    
    //Back to Profile View Controller
    @IBAction func backToProfile(segue: UIStoryboardSegue){}
    
    //Data
    var post : Post!
    var allPosts = [Post]()
    var userPosts = [Post]()
    var selectedPost : Int = Int()
    
    
    @IBOutlet weak var spin: UIActivityIndicatorView!
    
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
  
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
    
    //Variables
    var currentUser : String = String()
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var posts: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var userInfoView: UIView!
    
    //Refresh control to manually update the Main Feed TableView
    var refreshControl: UIRefreshControl!
    
    
    @IBAction func showRatings(sender: UIButton) {
        performSegueWithIdentifier("ShowRecentUserFeedback", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.floatRatingView.delegate = self
        self.spin.startAnimating()
        self.spin.hidden = false
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
 
            
       // let timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(manualUpdate), userInfo: nil, repeats: true)
        
        floatRatingView.rating = 4.50
        setUpRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        //Fill in user info
        getCurrentUserData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Set up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let post = userPosts[indexPath.row]
        let cell : CustomTableCell = tableView.dequeueReusableCellWithIdentifier("ProfileCell")! as! CustomTableCell
        cell.configureCell(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if userPosts[indexPath.row].postComplete {
            showAlertView("Rate User", text: "Please select and rate a user", confirmButton: "Rate", cancelButton: "Later", callBack: "Rate")
        } else {
            selectedPost = indexPath.row
            performSegueWithIdentifier("detailSegue2", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    //Functions
    
    //Adds pull to refresh to the main table view
    func setUpRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(manualUpdate), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    //Update Firebase Data and Table View
    func updatePosts(){
        DataService.dataService.POST_REF.observeEventType(.Value, withBlock: { snapshot in
            self.allPosts = []
            self.userPosts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(key: key, dictionary: postDictionary)
                        self.allPosts.insert(post, atIndex: 0)
                    }
                }
            }
        
            //Get current users posts
            for i in self.allPosts
            {
                if i.username == self.currentUser{
                    self.userPosts.append(i)
                }
            }
            self.refreshControl.endRefreshing()
            self.spin.stopAnimating()
            self.spin.hidden = true
            self.tableView.reloadData()
            self.posts.text = "\(self.userPosts.count) Posts"
            self.userInfoView.hidden = false
            self.tableView.hidden = false
        })
    }
    
    func manualUpdate(){
        DataService.dataService.POST_REF.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.allPosts = []
            self.userPosts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(key: key, dictionary: postDictionary)
                        self.allPosts.insert(post, atIndex: 0)
                    }
                }
            }
            
            //Get current users posts
            for i in self.allPosts
            {
                if i.username == self.currentUser{
                    self.userPosts.append(i)
                }
            }
            self.refreshControl.endRefreshing()
            self.spin.stopAnimating()
            self.spin.hidden = true
            self.tableView.reloadData()
            self.posts.text = "\(self.userPosts.count) Posts"
            self.userInfoView.hidden = false
            self.tableView.hidden = false
        })

    }
    
    func renewListing(){
        
    }
    
    //Load current user information
    func getCurrentUserData(){
        DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            self.currentUser = snapshot.value.objectForKey("username") as! String
            let currentProfileImg = snapshot.value.objectForKey("profileImage") as! String
            let userRating : Float = Float(snapshot.value.objectForKey("rating") as! String)!
            self.ratingLabel.text = "\(snapshot.value.objectForKey("rating") as! String) Star Rating"

            self.floatRatingView.rating = userRating
            self.userName.text = self.currentUser
            
            
            let decodedData = NSData(base64EncodedString: currentProfileImg, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            
            let decodedimage = UIImage(data: decodedData!)
            
            self.profileImage.image = decodedimage! as UIImage
            
            self.updatePosts()
        })
    }
    
    //Alert to delete, mark as completed or rate
    func showAlertView(title: String?, text: String?, confirmButton: String?, cancelButton: String?, callBack: String){
        let alertview = JSSAlertView().show(
            self,
            title: title!,
            text: text!,
            buttonText: confirmButton!,
            cancelButtonText: cancelButton!
        )
        alertview.addAction(rateUser)
    }
    
    func rateUser(){
        performSegueWithIdentifier("LeaveFeedbackFromProfile", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailSegue2"){
            let details : PostDetails = segue.destinationViewController as! PostDetails
            details.key = userPosts[selectedPost].postKey
            details.previousVC = "Profile"
        }
        
        if segue.identifier == "LeaveFeedbackFromProfile"{
            let feedback : Feedback = segue.destinationViewController as! Feedback
            feedback.postKey = userPosts[selectedPost].postKey
            feedback.previousSegue = "Profile"
        }
        
        
        
        if segue.identifier == "ShowRecentUserFeedback"{
            let userFeedback : RecentFeedback = segue.destinationViewController as! RecentFeedback
            userFeedback.previousSegue = "Profile"
            userFeedback.username = currentUser
        }
    }
}
