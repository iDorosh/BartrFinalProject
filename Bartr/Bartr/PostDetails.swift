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
import SCLAlertView
import FirebaseDatabase



class PostDetails: UIViewController {
    
    //Back to Post Details View Controller
    @IBAction func backToPostDetails(segue: UIStoryboardSegue){}
    
    //Data
    var allOffers = [Offers]()
    var selectedOffers = [Offers]()
    var selectedPost = [Post]()
    
    
    
    //Variables
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
    var currentRating : String = String()
    var offertextFieldText = String()
    var currentUserNameString = String()
    //Listing key is passed from the previous screen to
    //add a view to the listing
    var key : String = String()
    var postKey : String = String()
    
    
    var rating : Float = Float()
    
    //Name of the previous view controller to show and
    //hide UI items
    var previousVC : String = String()
    
    //UID for offers and messages
    var recieverUID : String = ""
    var senderUID : String = ""
    
    //Search Amazon with edited title
    var titleEdit : String = String()
    var decodedimage2 = UIImage()


    
    var newOffers = 0
    var alertController = UIAlertController()

    @IBAction func backbuttonClicked(sender: UIButton) {
        unwind()
    }
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var extendOrRenew: UIButton!
  
    
    
    
    //Outlets
    
    //Views
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var amazonView: UIView!

    
    
    
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
        
    }

    @IBAction func renewOrExtendAction(sender: UIButton) {
        renewListing()
    }
    
    @IBAction func makeOfferAction(sender: UIButton) {
        //blurView.hidden = false
        //makeOfferView.hidden = false
        enterOffer()
        
    }
    
    func enterOffer(){
        self.alertController.dismissViewControllerAnimated(true, completion: nil)
        let alert = SCLAlertView()
        let txt = alert.addTextField("Make Offer")
        txt.autocapitalizationType = UITextAutocapitalizationType.Sentences
        alert.addButton("Send Offer") {
            self.sendOfferText(txt.text!)
        }
        alert.showEdit("Make Offer", subTitle: "Send \(selectedUser!) an offer for this listing")
    }

    @IBAction func hideOfferView(sender: UIButton) {
    }
    
    @IBAction func showProfile(sender: UIButton) {
        print("clicked")
        if key == FIRAuth.auth()?.currentUser?.uid{
            self.tabBarController?.tabBar.hidden = false
            self.tabBarController?.selectedIndex = 4
        
        } else {
            if previousVC != "UsersFeed" {
            performSegueWithIdentifier("showUsersProfileSegue", sender: self)
            }
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
        
    }
    
    @IBOutlet var firstView: UIView!
    
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePosts()
        
        
        
    }
    
    func updateViews(){
        let fixedWidth = postDetails.frame.size.width
        postDetails.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = postDetails.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = postDetails.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height+10)
        postDetails.frame = newFrame;
        
        let fixedWidth2 = descriptionView.frame.size.width
        descriptionView.sizeThatFits(CGSize(width: fixedWidth2, height: CGFloat.max))
        let newSize2 = descriptionView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame2 = descriptionView.frame
        newFrame2.size = CGSize(width: max(newSize2.width, fixedWidth2), height: newSize.height + 30)
        descriptionView.frame = newFrame2;
        
        locationView.frame.origin = CGPointMake(locationView.frame.origin.x, newSize.height + 398)
        
        socialView.frame.origin = CGPointMake(socialView.frame.origin.x, newSize.height + 609)
        
        amazonView.frame.origin = CGPointMake(amazonView.frame.origin.x, newSize.height + 720)
        
        if amazonView.hidden == false{
        detailScrollView.contentSize.height = amazonView.frame.origin.y + 1140
        mainView.hidden = false
        } else {
            detailScrollView.contentSize.height = newSize.height + 1010
            self.getNewOffers()
        }
        
        

    }

    override func viewDidDisappear(animated: Bool) {
        
        selectedPost.removeAll()
    }
    func setVariables(){
        let post = selectedPost[0]
        postKey = post.postKey
        key = post.postUID
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
        addTapRecognizer()
        loadUI()
    }
    
    func loadUI(){
        
        loadLabels()
        decodeImages()
        
        DataService.dataService.CURRENT_USER_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
            self.currentUserNameString = snapshot.value!.objectForKey("username") as! String
            currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
            self.ratingView.rating = Float(snapshot.value!.objectForKey("rating") as! String)!
            self.getSelectedUID()
            self.hideItems()
            self.updateViews()
            if self.key != FIRAuth.auth()?.currentUser?.uid{
                self.setMapLocation()
                self.loadWebView()
            }
        })
        
        
        
        var test : CGRect = postDetails.frame;
        test.size.height = postDetails.contentSize.height;
        postDetails.frame = test
        
        postDetails.scrollEnabled = false
        addView()
       
        
       

    }
    
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func getSelectedUID(){
        self.recieverUID = self.selectedPost[0].postUID
        self.senderUID = (FIRAuth.auth()?.currentUser?.uid)!
    }
    
    
    //Functions
    
    //Will hide UI elements depending on what the previous screen was
    func hideItems(){
       
        if (previousVC == "Profile"){
            delete.hidden = false
            message.hidden = true
            sold.hidden = false
            amazonView.hidden = true
            socialView.hidden = false
            locationView.hidden = false
            editButton.hidden = false
            mapView.hidden = true
            offerButton.hidden = true
            
            
            checkExperation()

            
            
            detailScrollView.contentSize.height = 1110
        } else if previousVC == "UsersFeed"{
            offerButton.hidden = false
            delete.hidden = true
            message.hidden = false
            sold.hidden = true
            amazonView.hidden = false
            socialView.hidden = false
            locationView.hidden = false
            editButton.hidden = true
             extendOrRenew.hidden = true
            detailScrollView.contentSize.height = 1950
        } else {
            offerButton.hidden = false
            delete.hidden = true
            message.hidden = false
            sold.hidden = true
            amazonView.hidden = false
            socialView.hidden = false
            locationView.hidden = false
            editButton.hidden = true
             extendOrRenew.hidden = true
            detailScrollView.contentSize.height = 1950
        }
        
   
        if (selectedPost[0].postUID == FIRAuth.auth()?.currentUser!.uid){
            delete.hidden = false
            message.hidden = true
            sold.hidden = false
            socialView.hidden = true
            editButton.hidden = false
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
        
        experationLabel.text = getExperationDate(selectedExperation!)

        totalViews = "\(selectedViews!)"
        
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
        postDetails.font = UIFont(name: "Avenir", size: 15)
        
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
    
    
    

    //Adding a view to the current listing if the click was from main feed or search
    func addView(){
        
        if previousVC != "Profile" {
            DataService.dataService.CURRENT_USER_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                FIRAuth.auth()?.currentUser?.uid
                if self.selectedPost[0].postUID != FIRAuth.auth()?.currentUser!.uid{
                    let updatedViews : Int = self.selectedViews! + 1
                    
                    let selectedPostRef = DataService.dataService.POST_REF.child(self.postKey)
                    let nickname = ["views": updatedViews]
                    
                    selectedPostRef.updateChildValues(nickname)
                }
            })
        }    }

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
        let selectedPostRef = DataService.dataService.POST_REF.child(postKey)
        selectedPostRef.removeValue()
        unwind()
    }
    
    //Displays that the user is not signed into an account
    func listingRemoved(title: String, message: String) {
        let alertView = JSSAlertView().show(self, title: title, text: message)
        alertView.addAction(goBack)
    }

    func goBack(){
        unwind()
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
        let selectedPostRef = DataService.dataService.POST_REF.child(self.key)
        selectedPostRef.updateChildValues([
            "postComplete": true,
            ])
        unwind()
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
        let selectedPostRef = DataService.dataService.POST_REF.child(postKey)
        selectedPostRef.updateChildValues([
            "postExpireDate": experationDate,
            ])
        
       
        extended()
    }
    
    
    func updatePosts(){
        self.view.endEditing(true)
        DataService.dataService.POST_REF.child(key).observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.selectedPost = []
            
            
            if snapshot.children.allObjects is [FIRDataSnapshot] {
                
                
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
            camera.editKey = postKey
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
            feedback.postKey = postKey
        }
        
        if segue.identifier == "NewMessage"{
            
            let chatVc : ChatViewController = segue.destinationViewController as! ChatViewController
            chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
            chatVc.recieverUsername = postUser.text!
            chatVc.senderDisplayName = ""
            chatVc.recieverUID = key
            chatVc.ref4 = ref
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
            offersVC.uid = senderUID
        }

    }
    
    func sendOfferText(offerTextString : String!){
        
            let itemRef = DataService.dataService.USER_REF.child(key).child("offers").childByAutoId() // 1
        
            sendOfferRef = itemRef
      
            let offerItem = [ // 2
                "senderUsername": currentUserNameString,
                "recieverUsername" : selectedUser,
                "recieverImage" : selectedProfileImg,
                "listingTitle": selectedTitle,
                "offerText" : offerTextString,
                "offerChecked" : "false",
                "offerAccepted" : "false",
                "offerDeclined" : "false",
                "currentProfileImage" : currentProfileImg,
                "senderUID" : senderUID,
                "senderRating" : String(ratingView.rating),
                "offerDate" : dateFormatter().stringFromDate(NSDate()),
                "offerStatus" : "Delivered"
        ]
        
        DataService.dataService.createNewOffer(offerItem)
        
        let itemRef2 = DataService.dataService.USER_REF.child(senderUID).child("offers").child(itemRef.key) // 1
        sendOfferRef = itemRef2
        
        DataService.dataService.createNewOffer(offerItem)
        
        self.view.endEditing(true)
        
       success()
    }
    
    func success(){
        let alertView = SCLAlertView()
        alertView.showSuccess("Offer Sent", subTitle: "Your offer has been sent to \(selectedUser!)")
    }
    
    func extended(){
        let alertView = SCLAlertView()
        alertView.showSuccess("Listing Extended", subTitle: "You listing will be available for the next 10 days")
    }
    
    var testing : String = "false"
    var hasOffers : Bool = false
    func getNewOffers(){
        
            hasOffers = false
            DataService.dataService.CURRENT_USER_REF.child("offers").observeSingleEventOfType(.Value, withBlock: { snapshot in
                // 3
                self.allOffers = []
                self.selectedOffers = []
                self.newOffers = 0
                print("new")
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots{
                        
                        if let offersDictionary = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let offer = Offers(key: key, dictionary: offersDictionary)
                            self.allOffers.insert(offer, atIndex: 0)
                        }
                    }
                    
                    for offers in self.allOffers{
                        if (offers.offerTitle == self.selectedTitle!){
                            self.hasOffers = true
                        }
                        if (offers.offerTitle == self.selectedTitle!) && (offers.offerChecked == "false") {
                            self.newOffers = self.newOffers + 1
                            print("new")
                            
                        }
                    }
                    self.sold.setTitle("\(String(self.newOffers)) New Offers", forState: .Normal)
                    self.mainView.hidden = false
                    
                }
                
                
                if (!self.hasOffers) {
                    self.sold.setTitle("No Offers", forState: .Normal)
                    self.mainView.hidden = false
                }
                

            })
        

    }
    
    
    func unwind(){
       
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
        
}
