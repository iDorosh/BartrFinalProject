//
//  Summary.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/14/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import SCLAlertView
import Social

class Summary: UIViewController {
    
    //Variables
    var previousVC : String = String()
    var postType : String = String()
    var pickedImage: UIImage = UIImage()
    var pickedTitle : String = String()
    var pickedLocation : String = String()
    var pickedTypes : String = String()
    var pickedDescription : String = String()
    var pickedPrice : String = String()
    var currentProfileImg : String = String()
    var base64String : String = String()
    var month : Int = Int()
    var day : Int = Int()
    var year : Int = Int()
    var editKey : String = String()
    
    //Outlets
    @IBOutlet weak var currentUser: UILabel!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var previewTitle: UILabel!
    @IBOutlet weak var previewUser: UILabel!
    @IBOutlet weak var previewLocation: UILabel!
    @IBOutlet weak var previewDescription: UITextView!
    @IBOutlet weak var previewType: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var previewPrice: UILabel!
    @IBOutlet weak var postLabel: UIButton!
    
    //Actions
    @IBAction func cancelButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("MainFeedUnwind", sender: self)
    }
    
    @IBAction func postListing(sender: UIButton) {
        addPostClicked()
    }
    
    @IBAction func discardListing(sender: UIButton) {
        showAlertView("Discard Listing", text: "Listing will be discarded", confirmButton: "Discard", cancelButton: "Cancel")
    }
    

    //Go back to details view
    @IBAction func backBttnAction(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //Get Current User
    func getCurrentUser(){
        DataService.dataService.CURRENT_USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            self.currentUser.text = snapshot.value!.objectForKey("username") as? String
            currentUserUID = snapshot.key
        })
    }
    
    //Set Images and Labels
    func loadLabels(){
        previewImage.image = pickedImage
        previewTitle.text = pickedTitle
        previewLocation.text = pickedLocation
        previewDescription.text = pickedDescription
        previewDescription.font = UIFont(name: "Avenir", size: 15)
        previewType.text = "\(pickedTypes)"
        previewPrice.text = pickedPrice
        if previousVC == "EditView"{
            postLabel.setTitle("Update Listing", forState: .Normal)
        }
    }
    
    //Get listing location on map preview
    func loadLocation(){
        let location: String = pickedLocation
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
    
    //Load UI
    override func viewDidLoad() {
        super.viewDidLoad()
        ScrollView.contentSize.height = 900
        getCurrentUser()
        loadLabels()
        loadLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Functions
    
    //Add post button clicked
    func addPostClicked() {
        if previousVC == "EditView"{
            encodePhoto(pickedImage)
            let postText = pickedDescription
            let postTitle = pickedTitle
            let postType = pickedTypes
            getCurrentDate()
            DataService.dataService.CURRENT_USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
                self.currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
                self.getCurrentUser()
            
            let selectedPostRef = DataService.dataService.POST_REF.child(self.editKey)
            selectedPostRef.updateChildValues([
                "postText": postText,
                "postTitle": postTitle,
                "postType": postType,
                "author": self.currentUser.text!,
                "postImage": self.base64String,
                "postLocation": self.pickedLocation,
                "userProfileImg": self.currentProfileImg,
                "postPrice": self.pickedPrice,
                ])
                self.performSegueWithIdentifier("GoBackToProfileSegue", sender: self)
            })
        } else {
            encodePhoto(pickedImage)
            uploadToFirebase()
        }
        
    }
    
    //Encode listing image to send as a string to Firebase
    func encodePhoto(image: UIImage){
        var data: NSData = NSData()
        data = UIImageJPEGRepresentation(image,0.0)!
        base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    //Gets current data for time stamp
    func getCurrentDate(){
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day, .Year], fromDate: date)
        month = components.month
        day = components.day
        year = components.year
    }
    
    //Alert to delete, mark as completed or rate
    func showAlertView(title: String?, text: String?, confirmButton: String?, cancelButton: String?){
        let alertview = JSSAlertView().show(
            self,
            title: title!,
            text: text!,
            buttonText: confirmButton!,
            cancelButtonText: cancelButton!
        )
        alertview.addAction(removeListing)
    }
    
    func removeListing(){
        performSegueWithIdentifier("MainFeedUnwind", sender: self)
    }
    


    //Upload the listing to firebase with current users profile image and username
    func uploadToFirebase(){
        let postText = pickedDescription
        let postTitle = pickedTitle
        let postType = pickedTypes
        let date = dateFormatter().stringFromDate(NSDate())
        let currentDate = NSDate()
        let experationDate = dateFormatter().stringFromDate(currentDate.dateByAddingTimeInterval(60*60*24*11))
        getCurrentDate()
        
        DataService.dataService.CURRENT_USER_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
            self.currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
            self.getCurrentUser()
            
    
            if postText != "" {
                // Build the new post.
                let newpost: Dictionary<String, AnyObject> = [
                    "postText": postText,
                    "postTitle": postTitle,
                    "views": 0,
                    "postType": postType,
                    "author": self.currentUser.text!,
                    "postImage": self.base64String,
                    "postLocation": self.pickedLocation,
                    "userProfileImg": self.currentProfileImg,
                    "postDate": date,
                    "postPrice": self.pickedPrice,
                    "postFeedbackLeft" : false,
                    "postUID" : currentUserUID,
                    "postComplete" : false,
                    "postExpireDate" : experationDate,
                    "postExpired" : false 
                ]
        
                DataService.dataService.createNewPost(newpost)
                self.success()
                self.tabBarController?.tabBar.hidden = false
            }
        })
    }
    
    
    func success(){
        let alertView = SCLAlertView()
        alertView.addButton("Twitter") {self.postToTwitter()}
        alertView.addButton("Facebook", target: self, selector: #selector (postToFacebook))
        alertView.addButton("Instagram", target: self, selector: #selector (postToInstagram))
        alertView.addButton("Done") { self.performSegueWithIdentifier("MainFeedUnwind", sender: self) }
        alertView.showCloseButton = false
        alertView.showSuccess("Listed", subTitle: "Would you like to share your new post on social media?")
    }
    
    func noAccount(){
        let alertView = SCLAlertView()
        alertView.addButton("Sign In", target: self, selector: #selector (openSettings))
        alertView.showError("No Account", subTitle: "Please sign into your account")
    }
    
    func openSettings(){
        let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsURL{
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func postToTwitter(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let tweetController = SLComposeViewController(forServiceType : SLServiceTypeTwitter)
            
            tweetController.setInitialText("Check out my new listing on Bartr!")
            
            tweetController.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                switch result {
                case SLComposeViewControllerResult.Cancelled:
                    self.performSegueWithIdentifier("MainFeedUnwind", sender: self)
                    break
                    
                case SLComposeViewControllerResult.Done:
                    self.performSegueWithIdentifier("MainFeedUnwind", sender: self)
                    break
                }
            }

            
            self.presentViewController(tweetController, animated: true, completion: nil)
        } else {
            noAccount()
        }
    }
    
    func postToFacebook(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let postController = SLComposeViewController(forServiceType : SLServiceTypeFacebook)
            
            postController.setInitialText("Check out my new listing on Bartr!")
            
            postController.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                switch result {
                case SLComposeViewControllerResult.Cancelled:
                    self.performSegueWithIdentifier("MainFeedUnwind", sender: self)
                    break
                    
                case SLComposeViewControllerResult.Done:
                    self.performSegueWithIdentifier("MainFeedUnwind", sender: self)
                    break
                }
            }
            
            self.presentViewController(postController, animated: true, completion: nil)
        } else {
            noAccount()
        }
    }
    
    func postToInstagram(){
        print("Instagram")
    }
}
