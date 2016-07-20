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

class Profile: UIViewController, UITableViewDataSource, FloatRatingViewDelegate{
    
    var segment = 0

    
    //Back to Profile View Controller
    @IBAction func backToProfile(segue: UIStoryboardSegue){}
    
    //Data
    var post : Post!
    var allPosts = [Post]()
    var userPosts = [Post]()
    var offers = [Offers]()
    var viewOffer : Offers!
    var selectedOffer : Offers!
    
    var recieverOffers = [Offers]()
    var sendOffers = [Offers]()
    var selectedPost : Int = Int()
    
    @IBOutlet weak var noOffersYet: UILabel!
    
    
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
            if userPosts.count == 0 {
                noOffersYet.text = "No Posts Yet"
                noOffersYet.hidden = false
            } else {
                noOffersYet.hidden = true
            }
            return userPosts.count
        } else if segment == 1{
            if recieverOffers.count == 0 {
                noOffersYet.text = "No Offers Yet"
                noOffersYet.hidden = false
            } else {
                noOffersYet.hidden = true
            }
            return recieverOffers.count
        } else {
            if sendOffers.count == 0 {
                noOffersYet.text = "No Offers Yet"
                noOffersYet.hidden = false
            } else {
                noOffersYet.hidden = true
            }
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
            performSegueWithIdentifier("detailSegue2", sender: self)
        } else if segment == 1 {
            viewOffer = recieverOffers[indexPath.row]
            if (viewOffer.offerDeclined == "true") {
                offerDeclined("Offer Canceled", subtitle: "The user has canceled their offer. Would you like to delete this offer now?")
            } else {
                performSegueWithIdentifier("ViewOfferSegue", sender: self)
            }
        } else {
            viewOffer = sendOffers[indexPath.row]
            if (viewOffer.offerDeclined == "true") {
                offerDeclined("Offer Declined", subtitle: "The user has declined your offer. Would you like to delete this offer now?")
            } else {
                performSegueWithIdentifier("ViewOfferSegue", sender: self)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if segment == 0 {
            return false
        } else if segment == 1 {
            return true
        } else {
            return true
        }
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
            selectedOffer = offers[indexPath.row]
            offers.removeAtIndex(indexPath.row)
            deleteOffer(selectedOffer)
    }
    
    func deleteOffer(offer : Offers){
        if segment == 1 {
            if (offer.offerDeclined == "false") {
                let updateRef = DataService.dataService.USER_REF.child("\(selectedOffer.offerUID)").child("offers").child("\(selectedOffer.offerKey)")
                updateRef.updateChildValues([
                    "offerStatus" : "Declined",
                    "offerDeclined" : "true"
                ])
            }
            
            let deleteRef = DataService.dataService.CURRENT_USER_REF.child("offers").child("\(selectedOffer.offerKey)")

            deleteRef.removeValue()
        } else if segment == 2 {
            if (offer.offerDeclined == "false") {
                let updateRef = DataService.dataService.USER_REF.child("\(selectedOffer.recieverUID)").child("offers").child("\(selectedOffer.offerKey)")
                updateRef.updateChildValues([
                    "offerStatus" : "Canceled",
                    "offerDeclined" : "true"
                    ])
            }
            
            let deleteRef = DataService.dataService.CURRENT_USER_REF.child("offers").child("\(selectedOffer.offerKey)")
            
            deleteRef.removeValue()
        }
        
        tableView.reloadData()
    }
    
    func offerDeclined(title : String, subtitle : String){
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.addButton("Delete Offer") {
            let deleteRef = DataService.dataService.CURRENT_USER_REF.child("offers").child("\(self.viewOffer.offerKey)")
            deleteRef.removeValue()
            self.tableView.reloadData()}
        alertView.addButton("Cancel"){ alertView.dismissViewControllerAnimated(true, completion: nil) }
        alertView.showWarning(title, subTitle: subtitle)
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
        DataService.dataService.CURRENT_USER_REF.child("offers").observeEventType(.Value, withBlock: { snapshot in
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
                    if i.offerStatus == "Delivered"{
                        self.tabBarController?.tabBar.items?[4].badgeValue = "1"
                    }
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
        
       
        
        if (segue.identifier == "ViewOfferSegue"){
            let offer : ViewOffers = segue.destinationViewController as! ViewOffers
            offer.offer = viewOffer
            offer.uid = viewOffer.offerUID
            offer.postKey = viewOffer.listingKey
            offer.previousProfile = true
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
    
    
    
}
