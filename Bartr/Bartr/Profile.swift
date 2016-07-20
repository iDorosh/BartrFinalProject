//
//  Profile.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SCLAlertView

class Profile: UIViewController, UITableViewDataSource, FloatRatingViewDelegate, CustomIOS8AlertViewDelegate {
    
    var segment = 0
    var customFilterView : CustomIOS8AlertView! = nil
    
    //Back to Profile View Controller
    @IBAction func backToProfile(segue: UIStoryboardSegue){}
    
    //Data
    var post : Post!
    var allPosts = [Post]()
    var userPosts = [Post]()
    var offers = [Offers]()
    var viewOffer : Offers!
    
    var recieverOffers = [Offers]()
    var sendOffers = [Offers]()
    var selectedPost : Int = Int()
    
    @IBOutlet weak var ratings: UIView!
    @IBOutlet weak var setFeedback: FloatRatingView!
    
    @IBOutlet var typeofView: UISegmentedControl!
    
    
    
    @IBOutlet weak var spin: UIActivityIndicatorView!
    
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
  
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
    
    @IBAction func typeofViewActions(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            segment = 0
        case 1:
            segment = 1
        case 2:
            segment = 2
        default:
            break
        }
        tableView.reloadData()
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
        observeOffers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Set up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segment == 0 {
            return userPosts.count
        } else if segment == 1{
            return recieverOffers.count
        } else {
            return sendOffers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if segment == 0 {
        let post = userPosts[indexPath.row]
        let cell : CustomTableCell = tableView.dequeueReusableCellWithIdentifier("ProfileCell")! as! CustomTableCell
        cell.configureCell(post)
        self.tableView.rowHeight = 352.0
          self.tableView.hidden = false
        return cell
        } else if segment == 1{
            let offer = recieverOffers[indexPath.row]
            let cell : FeedbackTableCell = tableView.dequeueReusableCellWithIdentifier("FeedbackCell")! as! FeedbackTableCell
            cell.tableConfig(offer)
            self.tableView.rowHeight = 96.0
            self.tableView.hidden = false
            return cell
        } else {
            let offer = sendOffers[indexPath.row]
            let cell : FeedbackTableCell = tableView.dequeueReusableCellWithIdentifier("FeedbackCell")! as! FeedbackTableCell
            cell.tableConfig(offer)
            self.tableView.rowHeight = 96.0
            self.tableView.hidden = false
            return cell
        }
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if segment == 0 {
            if userPosts[indexPath.row].postComplete {
                success("Rate User", subTitle: "Would you like to rate this user and mark the Bartr as complete?")
            } else {
                selectedPost = indexPath.row
                performSegueWithIdentifier("detailSegue2", sender: self)
            }
        } else if segment == 1 {
            viewOffer = recieverOffers[indexPath.row]
            if viewOffer.offerAccepted == "true" {
                success("Rate User", subTitle: "Would you like to rate this user and mark the Bartr as complete?")
            } else {
                performSegueWithIdentifier("ViewOffer", sender: self)
            }
        } else {
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    //Functions
    
    func success(title : String, subTitle : String){
        let alertView = SCLAlertView()
        alertView.addButton("Rate User"){
            self.leaveFeedback()
        }
        alertView.addButton("Later"){
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showCloseButton = false
        alertView.showSuccess(title, subTitle: subTitle)
    }
    
    func leaveFeedback(){
        customFilterView = CustomIOS8AlertView()
        customFilterView.delegate = self
        customFilterView.containerView = ratings
        customFilterView.buttonColor = hexStringToUIColor("#2b3146")
        customFilterView.buttonColorHighlighted = hexStringToUIColor("#a6a6a6")
        customFilterView.buttonTitles = ["Send Feedback"]
        customFilterView.tintColor = hexStringToUIColor("#f27163")
        customFilterView.containerView.frame = CGRectMake(customFilterView.containerView.frame.minX , customFilterView.containerView.frame.minY, customFilterView.containerView.frame.width , customFilterView.containerView.frame.height - 120)
        customFilterView.show()
    }
    
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
                if i.postUID == FIRAuth.auth()?.currentUser?.uid{
                    self.userPosts.append(i)
                }
            }
            self.refreshControl.endRefreshing()
            self.spin.stopAnimating()
            self.spin.hidden = true
            self.tableView.reloadData()
            self.posts.text = "\(self.userPosts.count) Posts"
            self.observeOffers()
        })
    }
    
    func manualUpdate(){
        DataService.dataService.POST_REF.observeSingleEventOfType(.Value, withBlock: { snapshot in
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
                if i.username == self.currentUser{
                    self.userPosts.append(i)
                }
            }
            self.refreshControl.endRefreshing()
            self.spin.stopAnimating()
            self.spin.hidden = true
            self.tableView.reloadData()
            self.posts.text = "\(self.userPosts.count) Posts"
            })

    }
    
    
    func renewListing(){
        
    }
    
    //Load current user information
    func getCurrentUserData(){
        self.offers = []
        
        DataService.dataService.CURRENT_USER_REF.observeEventType(.Value, withBlock: { snapshot in
            self.currentUser = snapshot.value!.objectForKey("username") as! String
            let currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
            let userRating : Float = Float(snapshot.value!.objectForKey("rating") as! String)!
            self.ratingLabel.text = "\(snapshot.value!.objectForKey("rating") as! String) Star Rating"

            self.floatRatingView.rating = userRating
            self.userName.text = self.currentUser
            
            
            let decodedData = NSData(base64EncodedString: currentProfileImg, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            
            let decodedimage = UIImage(data: decodedData!)
            
            self.profileImage.image = decodedimage! as UIImage
            
            
            self.updatePosts()
        })
    }
    
    func observeOffers() {
        DataService.dataService.CURRENT_USER_REF.child("offers").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // 3
            self.offers = []
            self.sendOffers = []
            self.recieverOffers = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots{
                    
                    if let offersDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let offer = Offers(key: key, dictionary: offersDictionary)
                        self.offers.insert(offer, atIndex: 0)
                    }
                }
            }
            
            for i in self.offers {
                if i.offerUID == FIRAuth.auth()?.currentUser?.uid{
                    self.sendOffers.append(i)
                } else {
                    self.recieverOffers.append(i)
                    
                }
            }
            self.tableView.reloadData()
            self.tableView.hidden = false
        })
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
        
        if segue.identifier == "ViewOffer"{
            let offer : ViewOffers = segue.destinationViewController as! ViewOffers
            offer.offer = viewOffer
            offer.uid = (FIRAuth.auth()?.currentUser?.uid)!
            offer.postKey = viewOffer.offerKey
            offer.previousProfile = true
        }
    }
    
    func customIOS8AlertViewButtonTouchUpInside(alertView: CustomIOS8AlertView, buttonIndex: Int) {
        customFilterView.close()
    }
}
