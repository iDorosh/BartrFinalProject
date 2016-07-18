//
//  UsersProfile.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/22/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class UsersProfile: UIViewController, UITableViewDataSource {
    
     @IBAction func backToUsersProfile(segue: UIStoryboardSegue){}
    
    
    
    @IBOutlet weak var ratingLabel: UILabel!
    var usersName : String = String()
    var profileUIImage : UIImage = UIImage()
    var ratingString : String = String()
    var previousScreen : String = String()
    
    @IBOutlet weak var floatRating: FloatRatingView!
    
    @IBOutlet weak var spin: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePosts()
        self.spin.startAnimating()
        self.spin.hidden = false
        updateFeedback()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var post : Post!
    var allPosts = [Post]()
    var userPosts = [Post]()
    var selectedPost : Int = Int()
    
    @IBAction func openUserRating(sender: UIButton) {
        performSegueWithIdentifier("otherUserFeedbackSegue", sender: self)
    }
    
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        userNameLabel.text = usersName
        ratingLabel.text = ratingString
        profileImage.image = profileUIImage
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
        selectedPost = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("detailSegue2", sender: self)
    }
    

    //Update Firebase Data and Table View
    func updatePosts(){
        DataService.dataService.POST_REF.observeEventType(.Value, withBlock: { snapshot in
            self.allPosts = []
            self.userPosts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
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
                if i.username == self.usersName && !i.postComplete && !i.postFL{
                    self.userPosts.append(i)
                }
            }
            
            self.spin.stopAnimating()
            self.spin.hidden = true
            self.tableView.reloadData()
            self.posts.text = "\(self.userPosts.count) Posts"
            self.userInfoView.hidden = false
            self.tableView.hidden = false
        })
    }
    

    func updateFeedback(){
        DataService.dataService.USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value!.objectForKey("username") as! String
                    if (test == self.usersName){
                        self.floatRating.rating = Float(snap.value!.objectForKey("rating") as! String)!
                        self.ratingLabel.text = "\(snap.value!.objectForKey("rating") as! String) Star Rating"
                    }
                }
            }
            
        })

    }
    
    //Send data to the Detail View
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "detailSegue2"){
            let details : PostDetails = segue.destinationViewController as! PostDetails
            details.key = userPosts[selectedPost].postKey
            details.previousVC = "UsersFeed"
        }
        
        if segue.identifier == "otherUserFeedbackSegue"{
            let userFeedback : RecentFeedback = segue.destinationViewController as! RecentFeedback
            userFeedback.previousSegue = "UsersProfile"
            userFeedback.username = usersName
        }
    }
    
    


}
