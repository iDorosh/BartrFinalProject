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
    
    //Back to Post Details View Controller
    @IBAction func backToPostDetails(segue: UIStoryboardSegue)
    {
    }
  
    //Variables
    
    //Listing key is passed from the previous screen to
    //add a view to the listing
    var key : String = String()
    
    //Current views for the listing
    var postViews : Int = Int()
    
    var currentUser : String = String()
    
    //Name of the previous view controller to show and
    //hide UI items
    var previousVC : String = String()
    
    //Data passed from the previous screen
    var selectedTitle: String?
    var selectedProfileImg: String?
    var selectedImage: String?
    var selectedPrice: String?
    var selectedUser: String?
    var selectedLocation: String?
    var selectedDetails: String?
    var selectedType: String?
    
    var titleEdit : String = String()
    
    var decodedimage2 = UIImage()
    
    
    //Outlets
    
    //UI Elements
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
    }
    
    //Delete post
    @IBAction func deletePost(sender: UIButton) {
        showAlertView("Delete Listing", text: "Are you sure that you want to remove this listing?", confirmButton: "Remove", cancelButton: "Cancel", callBack: "Delete")
    }
    
    @IBAction func editPost(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    
    //Mark as sold/traded or given away
    @IBAction func soldAction(sender: UIButton) {
        showAlertView("Bartr Complete", text: "Please confirm a completed transaction", confirmButton: "Confirm", cancelButton: "Cancel", callBack: "Complete")
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
        //self.tabBarController?.tabBar.hidden = true
        
        //SetupUI
        hideItems()
        addTapRecognizer()
        loadWebView()
        loadLabels()
        decodeImages()
        
        
       
    }
    
    override func viewDidLoad() {
        //Add a view to selected listing
        addView()
        setMapLocation()
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Functions
    
    //Will hide UI elements depending on what the previous screen was
    func hideItems(){
        if (previousVC == "Profile"){
            delete.hidden = false
            message.hidden = true
            sold.hidden = false
            webView.hidden = true
            twitterButton.hidden = true
            fbbutton.hidden = true
            instagrambutton.hidden = true
            sharePost.hidden = true
            editButton.hidden = false
            showProfileButton.hidden = true
            
            detailScrollView.contentSize.height = 1400
        } else if previousVC == "UsersFeed"{
            delete.hidden = true
            message.hidden = false
            sold.hidden = true
            webView.hidden = false
            twitterButton.hidden = false
            fbbutton.hidden = false
            instagrambutton.hidden = false
            sharePost.hidden = false
            editButton.hidden = true
            detailScrollView.contentSize.height = 1880
            showProfileButton.hidden = true
        } else {
            delete.hidden = true
            message.hidden = false
            sold.hidden = true
            webView.hidden = false
            twitterButton.hidden = false
            fbbutton.hidden = false
            instagrambutton.hidden = false
            sharePost.hidden = false
            editButton.hidden = true
            detailScrollView.contentSize.height = 1880
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
        postTitle.text = selectedTitle
        postPrice.text = "$199"
        postUser.text = selectedUser
        postLocation.text = selectedLocation
        postType.text = "    \(selectedType!)"
        postPrice.text = selectedPrice
        postDetails.text = selectedDetails
        postDetails.font = UIFont(name: "Avenir", size: 17)
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
    
    //Will show a larger view of the clicked image
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowLargeImage"){
            let largeImageView : ViewImageVC = segue.destinationViewController as! ViewImageVC
            largeImageView.showImage = postImage.image!
        }
        
        if (segue.identifier == "EditPostSegue"){
            let camera : Camera = segue.destinationViewController as! Camera
            camera.editedTitle = postTitle.text
            camera.editedPrice = postPrice.text
            camera.editedLocation = postLocation.text
            camera.editedPhoto = postImage.image
            camera.editedProfileImg = selectedProfileImg
            camera.editedUser = selectedUser
            camera.editedDetails = postDetails.text
            camera.editedType = selectedType!
            camera.editKey = key
            camera.previousScreen = "EditView"
            
        }
        
        if segue.identifier == "showUsersProfileSegue"{
            let usersProfile : UsersProfile = segue.destinationViewController as! UsersProfile
            usersProfile.usersName = selectedUser!
            usersProfile.profileUIImage = decodedimage2
            usersProfile.ratingString = "89%"
        }
        
        
        if segue.identifier == "LeaveFeedbackSegue"{
            let feedback : Feedback = segue.destinationViewController as! Feedback
            feedback.postKey = key
        }
    }

}
