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
    //Strings
    var previousVC : String = String()
    var postType : String = String()
    var pickedTitle : String = String()
    var pickedLocation : String = String()
    var pickedTypes : String = String()
    var pickedDescription : String = String()
    var pickedPrice : String = String()
    var currentProfileImg : String = String()
    var base64String : String = String()
    var editKey : String = String()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //UIImages
    var pickedImage: UIImage = UIImage()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Integers
    var month : Int = Int()
    var day : Int = Int()
    var year : Int = Int()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Doubles
    var longitude : Double = Double()
    var latitude : Double = Double()
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
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
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var mapViewBG: UIView!

//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Actions
    //Cancel Listing
    @IBAction func cancelButtonClicked(sender: UIButton) {
        discardNew("Discard Listing", subTitle: "Listing will be discared")
    }
    
    //Create listing
    @IBAction func postListing(sender: UIButton) {
        addPostClicked()
    }
    
    //Discard listing
    @IBAction func discardListing(sender: UIButton) {
        discardNew("Discard Listing", subTitle: "Listing will be discared")
    }
    
    //Go back to details view
    @IBAction func backBttnAction(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Load UI
    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}
    override func viewDidLoad() {
        super.viewDidLoad()
        ScrollView.contentSize.height = 900
        getCurrentUser()
        loadLabels()
        loadLocation()
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Functions
    //Setup UI
        //Get Current User
        func getCurrentUser(){
            self.currentUser.text = currentUsernameString
            currentUserUID = (FIRAuth.auth()?.currentUser!.uid)!
        }
        
        //Set Images and Labels
        func loadLabels(){
            previewImage.image = pickedImage
            previewTitle.text = pickedTitle
            previewLocation.text = pickedLocation
            previewDescription.text = pickedDescription
            previewDescription.font = UIFont(name: "Avenir", size: 15)
            previewType.text = "\(pickedTypes)"
            
            if previousVC == "EditView"{
                postLabel.setTitle("Update Listing", forState: .Normal)
            }
            
            //Adjusting text view height
            let fixedWidth = previewDescription.frame.size.width
            previewDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            let newSize = previewDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            var newFrame = previewDescription.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height+10)
            previewDescription.frame = newFrame;
            
            //Adjusting description view height to fit the description text view
            let fixedWidth2 = detailsView.frame.size.width
            detailsView.sizeThatFits(CGSize(width: fixedWidth2, height: CGFloat.max))
            let newSize2 = detailsView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            var newFrame2 = detailsView.frame
            newFrame2.size = CGSize(width: max(newSize2.width, fixedWidth2), height: newSize.height + 40)
            detailsView.frame = newFrame2;
            
            //Adjusting location view to compinsate for the extra or less room
            mapViewBG.frame.origin = CGPointMake(mapViewBG.frame.origin.x, newSize.height + 390)
        
            ScrollView.contentSize.height = newSize.height + 750
            
            let _currencyFormatter : NSNumberFormatter = NSNumberFormatter()
            _currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            _currencyFormatter.currencyCode = "USD"
            
            if pickedPrice != "Negotiable" {
                pickedPrice = _currencyFormatter.stringFromNumber(Int(pickedPrice)!)!;
                var str = pickedPrice
                
                if let dotRange = str.rangeOfString(".") {
                    str.removeRange(dotRange.startIndex..<str.endIndex)
                }
                pickedPrice = str
            }
            
            previewPrice.text = pickedPrice
            

        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Get Location
        //Get listing location on map preview
        func loadLocation(){
         
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
            annotation.title = "Test"
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(Double(latitude), Double(longitude)), span)
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(annotation)
        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Create Listing
        //Add post button clicked
        func addPostClicked() {
            //If coming from detail view then the listing will be updated
            if previousVC == "EditView"{
                encodePhoto(pickedImage)
                let postText = pickedDescription
                let postTitle = pickedTitle
                let postType = pickedTypes
                getCurrentDate()
                
                //Getting current user data
                DataService.dataService.CURRENT_USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
                    self.currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
                    self.getCurrentUser()
                
                //Creating object for push
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
                    "lon" : String(self.longitude) as String,
                    "lat" : String(self.latitude) as String
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
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Upload to firebase
        //Upload the listing to firebase with current users profile image and username
        func uploadToFirebase(){
            //Sets variable to be uploaded to firebase
            let postText = pickedDescription
            let postTitle = pickedTitle
            let postType = pickedTypes
            let date = dateFormatter().stringFromDate(NSDate())
            let currentDate = NSDate()
            let experationDate = dateFormatter().stringFromDate(currentDate.dateByAddingTimeInterval(60*60*24*11))
            getCurrentDate()
            
            //Gets current username and profile image
            DataService.dataService.CURRENT_USER_REF.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                self.currentProfileImg = snapshot.value!.objectForKey("profileImage") as! String
                self.getCurrentUser()
                
                //Creating a object to push to firebase
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
                        "postExpired" : false,
                        "lon" : String(self.longitude) as String,
                        "lat" : String(self.latitude) as String
                    ]
            
                    //Setting alert and unhiding the tab bar
                    DataService.dataService.createNewPost(newpost)
                    self.success()
                    self.tabBarController?.tabBar.hidden = false
                }
            })
        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Alerts
    
        //Social media alert
        func success(){
            let alertView = SCLAlertView()
            alertView.addButton("Twitter") {self.postToTwitter()}
            alertView.addButton("Facebook", target: self, selector: #selector (postToFacebook))
            alertView.addButton("Done") { self.performSegueWithIdentifier("MainFeedUnwind", sender: self) }
            alertView.showCloseButton = false
            alertView.showSuccess("Listed", subTitle: "Would you like to share your new post on social media?")
        }
    
        //No Account for either twitter or facebook
        func noAccount(){
            let alertView = SCLAlertView()
            alertView.addButton("Sign In"){
                self.removeListing()
                self.openSettings()
            }
            alertView.addButton("Cancel"){
                self.removeListing()
            }
            alertView.showCloseButton = false
            alertView.showWarning("No Account", subTitle: "Please sign into your account")
        }
    
        //Open Setting to sign in
        func openSettings(){
            let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsURL{
                UIApplication.sharedApplication().openURL(url)
            }
        }
    
        //Discard Listing
        func discardNew(title : String, subTitle : String){
            let alertView = SCLAlertView()
            alertView.showCloseButton = false
            alertView.addButton("Discard") {
                self.removeListing()
            }
            alertView.addButton("Don't Discard") {
                alertView.dismissViewControllerAnimated(true, completion: nil)
            }
            alertView.showWarning(title, subTitle: subTitle)
        }
    
    //Remove Listing
        func removeListing(){
            performSegueWithIdentifier("MainFeedUnwind", sender: self)
        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Social Media
        //Post to twitter
        func postToTwitter(){
            //Check if the user is logged into twitter
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
                let tweetController = SLComposeViewController(forServiceType : SLServiceTypeTwitter)
                
                //Create initail text
                tweetController.setInitialText("I just made a listing! Look for \(previewTitle.text) in the Bartr app")
                tweetController.addImage(previewImage.image)
                
                //Unwinds to main feed when complete
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
                //Presents tweet view controller
                self.presentViewController(tweetController, animated: true, completion: nil)
            } else {
                //No account opens settings
                noAccount()
            }
        }
    
        //Post to facebook
        func postToFacebook(){
            //Check if the user is signed in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
                let postController = SLComposeViewController(forServiceType : SLServiceTypeFacebook)
                
                //Set initail text
                postController.setInitialText("I just made a listing! Look for \(previewTitle.text) in the Bartr app")
                postController.addImage(previewImage.image)
                
                //Completion handler to go back to main feed
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
                //Present facebook controller
                self.presentViewController(postController, animated: true, completion: nil)
            } else {
                //no account found go to settings alert
                noAccount()
            }
        }

//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
}
