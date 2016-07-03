//
//  PostDetails.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/17/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import MapKit
import Social
import Firebase



class PostDetails: UIViewController {
    
    var ref = Firebase(url: BASE_URL)

    
    var selectedPost = [Post]()
    
    
    //Back to Post Details View Controller
    @IBAction func backToPostDetails(segue: UIStoryboardSegue)
    {
    }
    
    
    @IBOutlet weak var ratingView: FloatRatingView!
    
    
    @IBOutlet weak var extendOrRenew: UIButton!
  
    //Variables
    
    //Listing key is passed from the previous screen to
    //add a view to the listing
    var key : String = String()
    
    //Current views for the listing
    var postViews : Int = Int()
    
    var currentUser : String = ""
    
    //Name of the previous view controller to show and
    //hide UI items
    var previousVC : String = String()
    
    var recieverUID : String = ""
    var senderUID : String = ""
    
    //Data passed from the previous screen
    var selectedTitle: String?
    var selectedProfileImg: String?
    var selectedImage: String?
    var selectedPrice: String?
    var selectedUser: String?
    var selectedLocation: String?
    var selectedDetails: String?
    var selectedType: String?
    var selectedTime: String?
    var selectedViews : Int?
    var selectedExperation : String?
    var expireString : String = String()
    
    
    var titleEdit : String = String()
    
    var decodedimage2 = UIImage()
    
    
    //Outlets
    
    //Views
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var amazonView: UIView!
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var makeOfferView: UIView!
    
    
    
    //UI Elements
    @IBOutlet weak var offerString: UITextView!
    
    @IBOutlet weak var makeOfferButton: UIButton!
    
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var twitterButton: UIButton!
    
    @IBOutlet weak var fbbutton: UIButton!
    
    @IBOutlet weak var instagrambutton: UIButton!
    
    @IBOutlet weak var sharePost: UILabel!
    
    @IBOutlet weak var delete: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var detailScrollView: UIScrollView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var message: UIButton!
    
    @IBOutlet weak var sold: UIButton!
    
    @IBOutlet weak var experationLabel: UILabel!
    
    
    //Labels and images for the selected post
    @IBOutlet weak var postUserProfileImg: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postPrice: UILabel!
    @IBOutlet weak var postUser: UILabel!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var postDetails: UITextView!
    @IBOutlet weak var postType: UILabel!
    @IBOutlet weak var showProfileButton: UIButton!
    @IBOutlet weak var offerButton: UIButton!
    

    
    @IBAction func sendOffer(sender: UIButton) {
        sendOffer()
    }

    @IBAction func renewOrExtendAction(sender: UIButton) {
        renewListing()
    }
    
    @IBAction func makeOfferAction(sender: UIButton) {
        blurView.hidden = false
        makeOfferView.hidden = false
        
    }

    @IBAction func hideOfferView(sender: UIButton) {
        blurView.hidden = true
        makeOfferView.hidden = true
    }
    
    @IBAction func showProfile(sender: UIButton) {
        if postUser.text == currentUser{
            self.tabBarController?.tabBar.hidden = false
            self.tabBarController?.selectedIndex = 4
        
        } else {
            performSegueWithIdentifier("showUsersProfileSegue", sender: self)
        }
        
    }
    
    //Send User a message
    @IBAction func messageAction(sender: UIButton) {
        performSegueWithIdentifier("NewMessage", sender: self)
    }
    
    //Delete post
    @IBAction func deletePost(sender: UIButton) {
        showAlertView("Delete Listing", text: "Are you sure that you want to remove this listing?", confirmButton: "Remove", cancelButton: "Cancel", callBack: "Delete")
    }
    
    @IBAction func editPost(sender: UIButton) {
        performSegueWithIdentifier("EditCurrentListing", sender: self)
        
    }
    
    //Mark as sold/traded or given away
    @IBAction func viewOffersAction(sender: UIButton) {
        performSegueWithIdentifier("LeaveFeedbackSegue", sender: self)
    }
    
    //Share on Twitter
    @IBAction func makeTweet(sender: UIButton) {
        postTweet()
    }
    
    @IBAction func backButton(sender: UIButton) {
        if previousVC == "Profile"{
            performSegueWithIdentifier("FinishedSegue", sender: self)
        } else if previousVC == "UsersFeed"{
            self.navigationController?.popViewControllerAnimated(true)
        } else if previousVC == "Search"{
            performSegueWithIdentifier("BackToSearchSegue", sender: self)
        } else {
            performSegueWithIdentifier("MainFeedUnwind", sender: self)
        }
    }
    
    
    //Webview Actions
    
    //Previous Page
    @IBAction func back(sender: UIButton) {
        webView.goBack()
    }
    
    //Next Page
    @IBAction func forward(sender: UIButton) {
        webView.goForward()
    }
    
    //Refresh Page
    @IBAction func refresh(sender: UIButton) {
        webView.reload()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false
        updatePosts()
        //SetupUI
        
        
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    func setVariables(){
        let post = selectedPost[0]
        selectedTitle = post.postTitle
        selectedProfileImg = post.postUserImage
        selectedImage = post.postImage
        selectedUser = post.username
        selectedLocation = post.postLocation
        selectedDetails = post.postText
        selectedType = post.postType
        selectedViews = post.postviews
        selectedPrice = post.postPrice
        selectedTime = post.postDate
        selectedExperation = post.expireDate
        key = post.postUID
        addTapRecognizer()
        loadUI()
    }
    
    func loadUI(){
        loadWebView()
        loadLabels()
        decodeImages()
        
        DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            self.currentUser = snapshot.value.objectForKey("username") as! String
            
            //Add a view to selected listing
            self.addView()
            self.setMapLocation()
            self.getSelectedUID()
            self.hideItems()
        })
        
        getUserInfo()
        
        var test : CGRect = postDetails.frame;
        test.size.height = postDetails.contentSize.height;
        postDetails.frame = test
        
        postDetails.scrollEnabled = false
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.blurView.addSubview(blurEffectView)
        
        updateFeedback(selectedUser!)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getSelectedUID(){
        DataService.dataService.USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value.objectForKey("username") as! String
                    if (test == self.selectedUser){
                        self.recieverUID = snap.key
                    }
                }
            }
            
        })
        
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
    
    
    //Functions
    
    //Will hide UI elements depending on what the previous screen was
    func hideItems(){
       
        if (previousVC == "Profile"){
            delete.hidden = false
            message.hidden = true
            sold.hidden = false
            amazonView.hidden = false
            socialView.hidden = false
            locationView.hidden = false
            editButton.hidden = false
            showProfileButton.hidden = true
            mapView.hidden = true
            offerButton.hidden = true
            
            
            checkExperation()

            
            
            detailScrollView.contentSize.height = 1110
        } else if previousVC == "UsersFeed"{
            delete.hidden = true
            message.hidden = false
            sold.hidden = true
            amazonView.hidden = false
            socialView.hidden = false
            locationView.hidden = false
            editButton.hidden = true
            offerButton.hidden = false
             extendOrRenew.hidden = true
            detailScrollView.contentSize.height = 1950
            showProfileButton.hidden = true
        } else {
            delete.hidden = true
            message.hidden = false
            sold.hidden = true
            amazonView.hidden = false
            socialView.hidden = false
            locationView.hidden = false
            editButton.hidden = true
            offerButton.hidden = false
             extendOrRenew.hidden = true
            detailScrollView.contentSize.height = 1950
        }
        
   
        if (postUser.text! == currentUser){
            delete.hidden = false
            message.hidden = true
            sold.hidden = false
            socialView.hidden = true
            editButton.hidden = false
            showProfileButton.hidden = true
            locationView.hidden = true
            amazonView.hidden = true
            offerButton.hidden = true
             checkExperation()
            detailScrollView.contentSize.height = 1110
        }
    }
    
    //Will open a larger view for the image
    func addTapRecognizer(){
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageClicked))
        postImage.userInteractionEnabled = true
        postImage.addGestureRecognizer(tap)
    }
    
    //Perform segue for selected Image
    func imageClicked(){
        performSegueWithIdentifier("ShowLargeImage", sender: self)
    }
    
    //Will load the url in the webview based on the title
    func loadWebView(){
        titleEdit = selectedTitle!.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let url = NSURL (string: "https://www.amazon.com/gp/aw/s/ref=is_s_ss_i_4_18?k=\(titleEdit)");
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
    }
    
    //Loads all information into the labels
    func loadLabels(){
        let dateString : String = selectedTime!
        
        let date = dateFormatter().dateFromString(dateString)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        var viewsOrView : String = "View"
        var totalViews : String = ""
        
        if currentUser != selectedUser {
            totalViews = "\(selectedViews! + 1)"
        } else {
            totalViews = "\(selectedViews!)"
        }
        
        experationLabel.text = getExperationDate(selectedExperation!)

        
        if (selectedViews > 1){
            viewsOrView = "Views"
            viewsLabel.text = "\(totalViews) \(viewsOrView)"
        } else if selectedViews == 0 {
            viewsOrView = "No Views"
            viewsLabel.text = viewsOrView
        } else {
            viewsOrView = "View"
            viewsLabel.text = "\(totalViews) \(viewsOrView)"
        }
        
        
        
        timeStamp.text = elapsedTime(seconds)
        postTitle.text = selectedTitle
        postPrice.text = "$199"
        postUser.text = selectedUser
        postLocation.text = selectedLocation
        postType.text = "\(selectedType!)"
        postPrice.text = selectedPrice
        postDetails.text = selectedDetails
        postDetails.font = UIFont(name: "Avenir", size: 13)
    }
    
    //Decodes images stored on Firbase
    func decodeImages(){
        let decodedData = NSData(base64EncodedString: selectedImage! , options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedimage = UIImage(data: decodedData!)
        
        postImage.image = decodedimage! as UIImage
        
        let decodedData2 = NSData(base64EncodedString: selectedProfileImg! , options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        decodedimage2 = UIImage(data: decodedData2!)!
       
        postUserProfileImg.image = decodedimage2 as UIImage
    }
    
    //Sets map to the location listed under the post.
    func setMapLocation(){
        let location: String = selectedLocation!
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count > 0) {
                let topResult: CLPlacemark = (placemarks?[0])!
                let placemark: MKPlacemark = MKPlacemark(placemark: topResult)
                var region: MKCoordinateRegion = self.mapView.region
                region.center = placemark.coordinate
                region.span.longitudeDelta /= 50.0
                region.span.latitudeDelta /= 50.0
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(placemark)
            }
        })
    }
    
    func updateFeedback(userName : String){
        DataService.dataService.USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value.objectForKey("username") as! String
                    if (test == userName){
                        self.ratingView.rating = Float(snap.value.objectForKey("rating") as! String)!
                    }
                }
            }
            
        })
        
    }

    
    
    //Adding a view to the current listing if the click was from main feed or search
    func addView(){
        
        if previousVC != "Profile" {
                DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
                    self.currentUser = snapshot.value.objectForKey("username") as! String
                    if self.selectedUser != self.currentUser{
                        let updatedViews : Int = self.postViews + 1

                        let selectedPostRef = DataService.dataService.POST_REF.childByAppendingPath(self.key)
                        let nickname = ["views": updatedViews]
                        
                        selectedPostRef.updateChildValues(nickname)
                    }
                })
        }
    }

    //Creates a Tweet using the account on the device
    func postTweet(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let tweetController = SLComposeViewController (forServiceType: SLServiceTypeTwitter)
            tweetController.setInitialText("I just list this on Bartr, go check it out! \(selectedTitle!)")
            
            self.presentViewController(tweetController, animated: true, completion: nil)
        } else {
            loginErrorAlert("Twitter", message: "Please sign into a Twitter Account")
        }
    }
    
    //Displays that the user is not signed into an account
    func loginErrorAlert(title: String, message: String) {
        JSSAlertView().show(self, title: title, text: message)
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
        
        //Will call the correct function based on what alert was sent
        switch callBack {
        case "Delete":
            alertview.addAction(deletePostCallBack)
        case "Complete":
            alertview.addAction(completeCallBack)
        case "Rate":
            alertview.addAction(rateCallBack)
            alertview.addCancelAction(rateLater)
        default:
            break
        }
    }
    
    //Removes post using post key
    func deletePostCallBack(){
        let selectedPostRef = DataService.dataService.POST_REF.childByAppendingPath(key)
        selectedPostRef.removeValue()
        performSegueWithIdentifier("FinishedSegue", sender: self)
    }
    
    //Shows rate user alert view
    func completeCallBack(){
        showAlertView("Rate User", text: "Please select and rate a user", confirmButton: "Rate", cancelButton: "Later", callBack: "Rate")
    }
    
    //Will allow the current user to select and rate a user
    func rateCallBack(){
        performSegueWithIdentifier("LeaveFeedbackSegue", sender: self)
    }
    
    func rateLater(){
        let selectedPostRef = DataService.dataService.POST_REF.childByAppendingPath(self.key)
        selectedPostRef.updateChildValues([
            "postComplete": true,
            ])
        performSegueWithIdentifier("FinishedSegue", sender: self)
    }
    
    
    func checkExperation(){
        extendOrRenew.hidden = true
        let eDateString : String = selectedExperation!
        let eDate = dateFormatter().dateFromString(eDateString)
        
        let days = eDate!.daysFrom(NSDate())
        let eseconds = eDate!.secondsFrom(NSDate())
        
        if days == 0 || days == 1 || days == 2 {
            extendOrRenew.setTitle("Extend Listing", forState: .Normal)
            extendOrRenew.hidden = false
        }
        
        if eseconds < 0 {
            extendOrRenew.setTitle("Renew Listing", forState: .Normal)
            extendOrRenew.hidden = false
        }
    }
    
    
    func renewListing(){
        let currentDate = NSDate()
        let experationDate = dateFormatter().stringFromDate(currentDate.dateByAddingTimeInterval(60*60*24*11))
        let selectedPostRef = DataService.dataService.POST_REF.childByAppendingPath(key)
        selectedPostRef.updateChildValues([
            "postExpireDate": experationDate,
            ])
        
       
        _ = JSSAlertView().show(
            self,
            title: "Listing Extended",
            text: "Your listing has been extened and will expire in 10 days",
            buttonText: "Dismiss"
        )
    }
    
    
    func updatePosts(){
        DataService.dataService.POST_REF.childByAppendingPath(key).observeEventType(.Value, withBlock: { snapshot in
            self.selectedPost = []
            
            
            if snapshot.children.allObjects is [FDataSnapshot] {
                
                
                if let postDictionary = snapshot.value as? Dictionary<String, AnyObject> {
                    let key = snapshot.key
                    let post = Post(key: key, dictionary: postDictionary)
                    self.selectedPost.insert(post, atIndex: 0)
                    self.setVariables()
                } else {
                    //self.navigationController?.popViewControllerAnimated(true)
                }
            }
            
        })
    }

    
    //Will show a larger view of the clicked image
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowLargeImage"){
            let largeImageView : ViewImageVC = segue.destinationViewController as! ViewImageVC
            largeImageView.showImage = postImage.image!
        }
        
        if (segue.identifier == "EditCurrentListing"){
            let camera : Camera = segue.destinationViewController as! Camera
            camera.editKey = key
            camera.previousScreen = "EditView"
            camera.orignalView = previousVC
            
        }
        
        if segue.identifier == "showUsersProfileSegue"{
            let usersProfile : UsersProfile = segue.destinationViewController as! UsersProfile
            usersProfile.usersName = selectedUser!
            usersProfile.profileUIImage = decodedimage2
        }
        
        
        if segue.identifier == "LeaveFeedbackSegue"{
            let feedback : Feedback = segue.destinationViewController as! Feedback
            feedback.postKey = key
        }
        
        if segue.identifier == "NewMessage"{
            
            let chatVc : ChatViewController = segue.destinationViewController as! ChatViewController
            chatVc.senderId = DataService.dataService.USER_REF.authData.uid
            chatVc.recieverUsername = postUser.text!
            chatVc.senderDisplayName = ""
            chatVc.recieverUID = recieverUID
            chatVc.ref = ref
            chatVc.selectedTitle = selectedTitle!
            chatVc.selectedImage = selectedProfileImg!
            chatVc.selectedUser = selectedUser!
            chatVc.currentUser = currentUser
            chatVc.senderUID = senderUID
            chatVc.title = selectedUser
          
        }
        
        if segue.identifier == "LeaveFeedbackSegue"{
            
            let offersVC : Feedback = segue.destinationViewController as! Feedback
            offersVC.selectedTitle = selectedTitle!
        }

    }
    
    func sendOffer(){
        
            let itemRef = DataService.dataService.USER_REF.childByAppendingPath(selectedPost[0].postUID).childByAppendingPath("offers").childByAutoId() // 1
        
            sendOfferRef = itemRef
      
            let offerItem = [ // 2
                "senderUsername": currentUser,
                "listingTitle": selectedTitle,
                "offerText" : offerString.text,
                "offerChecked" : "false",
                "currentProfileImage" : currentProfileImg
                ]
        
        DataService.dataService.createNewOffer(offerItem)
        
        blurView.hidden = true
        makeOfferView.hidden = true
        self.view.endEditing(true)
        
        _ = JSSAlertView().show(
            self,
            title: "Offer Sent",
            text: "Your offer has been sent to \(selectedUser!)",
            buttonText: "Dismiss"
        )
    }
    
    
        
}
