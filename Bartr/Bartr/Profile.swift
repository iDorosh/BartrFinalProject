//
//  Profile.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class Profile: UIViewController, UITableViewDataSource {
    
    //Back to Profile View Controller
    @IBAction func backToProfile(segue: UIStoryboardSegue){}
    
    //Data
    var post : Post!
    var allPosts = [Post]()
    var userPosts = [Post]()
    var selectedPost : Int = Int()
    
  
    
    //Variables
    var currentUser : String = String()
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var posts: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var userInfoView: UIView!
    
    
    @IBAction func showRatings(sender: UIButton) {
        performSegueWithIdentifier("ShowRecentUserFeedback", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
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
            
            self.tableView.reloadData()
            self.posts.text = "\(self.userPosts.count) Posts"
            self.userInfoView.hidden = false
            self.tableView.hidden = false
        })
    }
    
    //Load current user information
    func getCurrentUserData(){
        DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            self.currentUser = snapshot.value.objectForKey("username") as! String
            let currentProfileImg = snapshot.value.objectForKey("profileImage") as! String
            self.userName.text = self.currentUser
            self.rating.text = "87%"
            
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
            details.selectedTitle = userPosts[selectedPost].postTitle
            details.selectedProfileImg = userPosts[selectedPost].postUserImage
            details.selectedImage = userPosts[selectedPost].postImage
            details.selectedUser = userPosts[selectedPost].username
            details.selectedLocation = userPosts[selectedPost].postLocation
            details.selectedDetails = userPosts[selectedPost].postText
            details.selectedType = userPosts[selectedPost].postType
            details.key = userPosts[selectedPost].postKey
            details.selectedPrice = userPosts[selectedPost].postPrice
            print(" Hello \(selectedPost)")
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
