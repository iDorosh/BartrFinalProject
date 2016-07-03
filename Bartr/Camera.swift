//
//  Camera.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class Camera: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBAction func backToPhoto(segue: UIStoryboardSegue){}
    
    var postForEdit = [Post]()
    
    //Variables
    var croppingEnabled: Bool = false
    var libraryEnabled: Bool = true
    var locationFound : Bool = false
    var base64String : NSString!
    var typeString : String = String()
    var imagePicker: UIImagePickerController!
    var capturedImage : UIImage = UIImage()
    let locationManager = CLLocationManager()
    var currentUsername = ""
    var orignalView : String = ""
    
    var previousScreen : String?
    var editedTitle : String?
    var editedPrice : String?
    var editedLocation : String?
    var editedPhoto : String?
    var editedType : String = String()
    var editedProfileImg : String?
    var editedUser : String?
    var editedDetails : String?
    var editKey : String = String()
    
    var decodedPreviewImage : UIImage = UIImage()
    
    
    //----Outlets----//
    
    //Title text field
    @IBOutlet weak var titleField: UITextField!
    //City text field
    @IBOutlet weak var cityField: UITextField!
    //Description Text Box
    @IBOutlet weak var textBox: UITextView!
    //PreviewImage
    @IBOutlet weak var previewImage: UIImageView!
    //BackgroundImage
    @IBOutlet weak var bgImage: UIImageView!
    //ScrollView
    @IBOutlet weak var scrollView: UIScrollView!
    //Price Field
    @IBOutlet weak var priceField: UITextField!
    //Title
    @IBOutlet weak var screenTitle: UILabel!
    
    
    
    //----Actions----//
    
    //Open Gallery
    @IBAction func takeImage(sender: UIButton) {
       openCamera()
    }
    
    //Open Library
    @IBAction func openLibrary(sender: AnyObject) {
        openLibrary()
    }
    
    //Permision not available
    @IBAction func libraryChanged(sender: AnyObject) {
        libraryEnabled = !libraryEnabled
    }
    
    //Crop
    @IBAction func croppingChanged(sender: AnyObject) {
        croppingEnabled = !croppingEnabled
    }
    
    
    @IBAction func discardListing(sender: UIButton) {
        showAlertView("Discard Listing", text: "Listing will be discarded", confirmButton: "Discard", cancelButton: "Cancel")
    }
    
    @IBAction func nextClicked(sender: UIButton) {
        performSegueWithIdentifier("NextInfoSegue", sender: self)
    }
    
    
    
    //Load UI
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        
    }
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        if previousScreen == "EditView"{
            updatePosts()
            self.tabBarController?.selectedIndex = 2
        } else {
            loadUI()
        }

    }
    
    func setVariables(){
        let post = postForEdit[0]
        editedTitle = post.postTitle
        editedPrice = post.postPrice
        editedLocation = post.postLocation
        editedPhoto = post.postImage
        editedProfileImg = post.postUserImage
        editedUser = post.username
        editedDetails = post.postText
        editedType = post.postType
        
        decodeImages()
        addTapRecognizer()
        
        loadUI()
    }
    
    func loadUI(){
        setUpTextFields()
        addBlurrEffect()
        addTapRecognizer()
        getCurrentUser()
        if previousScreen != "EditView"{
            setLocationManager()
            
        }
    }
    
    func decodeImages(){
        let decodedData = NSData(base64EncodedString: editedPhoto! , options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedimage = UIImage(data: decodedData!)
        
        decodedPreviewImage = decodedimage! as UIImage
        
    }


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //Functions
    
    //Text Field Set Up
    func setUpTextFields(){
        titleField.delegate = self
        cityField.delegate = self
        priceField.delegate = self
        
        if previousScreen == "EditView"{
            titleField.text = editedTitle
            priceField.text = editedPrice
            cityField.text = editedLocation
            screenTitle.text = "Edit About"
            previewImage.image = decodedPreviewImage
        } else {
            screenTitle.text = "About"
            titleField.text = ""
            cityField.text = ""
            priceField.text = ""
            previewImage.image = UIImage(named: "placeholderImg")
        }
        
    }
    
    //Next text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === titleField) {
            cityField.becomeFirstResponder()
        } else if (textField === cityField) {
            priceField.becomeFirstResponder()
        } else if (textField === priceField) {
            priceField.resignFirstResponder()
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
            
        } else {
        }
        return true
    }
    
    //Sets proper view postition when keyboard pops up
    func textFieldDidBeginEditing(textField: UITextField) {
        UIApplication.sharedApplication().statusBarHidden = true
        if (textField == titleField){
            scrollView.setContentOffset(CGPointMake(0,200), animated: true)
        } else if (textField == cityField){
            scrollView.setContentOffset(CGPointMake(0,200), animated: true)
        } else if (textField == priceField){
            scrollView.setContentOffset(CGPointMake(0,200), animated: true)
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Resets view offset
        scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        view.endEditing(true)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    //Resets view
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == priceField){
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        }
    }
    
    //Add blur effect to the background image
    func addBlurrEffect(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.bgImage.addSubview(blurEffectView)
    }
    
    //Tap Recognizer to minimize the keyboard
    func addTapRecognizer(){
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Camera.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Get current user to add it to the listing details
    func getCurrentUser(){
        // Get username of the current user, and set it to currentUsername, so it can add it to the post.
        DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
            let currentUser = snapshot.value.objectForKey("username") as! String
            self.currentUsername = currentUser
            }, withCancelBlock: { error in
        })
    }
    
    //Set up loaction manager to get the current posistion
    func setLocationManager(){
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //Opening custom CameraViewController
    func openCamera()
    {
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            if (image != nil){
               self!.previewImage.image = image 
            }
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    //Opeing Library
    func openLibrary(){
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            self.previewImage.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    //Get Current Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        geoCoder.reverseGeocodeLocation(location)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
        
            if (!self.locationFound){
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString
                {
                  self.cityField.text = city as String + ", " + placeMark.administrativeArea!
                }
                self.locationFound = true
            }
        }
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
        titleField.text = ""
        cityField.text = ""
        priceField.text = ""
        previewImage.image = UIImage(named: "placeholderImg")
        if previousScreen == "EditView"{
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.tabBarController?.selectedIndex = 0
            
        }
        
    }
    
    //Sends data to next view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIApplication.sharedApplication().statusBarHidden = false
        
        if (segue.identifier == "NextInfoSegue"){
            if(previousScreen == "EditView"){
                let details : Details = segue.destinationViewController as! Details
                details.editType = editedType
                details.previousScreen = "EditView"
                details.pickedImage = previewImage.image!
                details.pickedTitle = titleField.text!
                details.pickedLocation = cityField.text!
                details.editProfileImg = editedProfileImg!
                details.editPhoto = previewImage.image!
                details.editUser = editedUser!
                details.editDetails = editedDetails!
                details.editKey = editKey
                details.pickedPrice = priceField.text!
    
                
            } else {
                let details : Details = segue.destinationViewController as! Details
                details.pickedImage = previewImage.image!
                details.pickedTitle = titleField.text!
                details.pickedLocation = cityField.text!
                if priceField.text == ""{
                    details.pickedPrice = priceField.placeholder!
                } else {
                    if !(priceField.text?.characters.contains("$"))!{
                        details.pickedPrice = "$\(priceField.text!)"
                    } else {
                        details.pickedPrice = priceField.text!
                    }
                }
            }
            
        }
    }
    
    func updatePosts(){
        DataService.dataService.POST_REF.childByAppendingPath(editKey).observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.postForEdit = []
            
            
            if snapshot.children.allObjects is [FDataSnapshot] {
                
                
                if let postDictionary = snapshot.value as? Dictionary<String, AnyObject> {
                    let key = snapshot.key
                    let post = Post(key: key, dictionary: postDictionary)
                    self.postForEdit.insert(post, atIndex: 0)
                    self.setVariables()
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            
        })
    }

}
