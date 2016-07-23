//
//  Camera.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import ALCameraViewController
import FirebaseDatabase
import SCLAlertView




class Camera: UIViewController, UITextFieldDelegate {
    
    @IBAction func backToPhoto(segue: UIStoryboardSegue){}
    
    var postForEdit = [Post]()
    
    var alertController = UIAlertController()
    
    var errorMessage : String = ""
    
    var defaultColor = UIColor()
    var defaultBorderColor = UIColor()
    var defaultLabelColor = UIColor()
    
    var cameraOpened : Bool = false
    
    @IBOutlet weak var requiredCharacterFields: UILabel!
    
    //Variables
    var croppingEnabled: Bool = false
    var libraryEnabled: Bool = true
    var locationFound : Bool = false
    var base64String : NSString!
    var typeString : String = String()
    var imagePicker: UIImagePickerController!
    var capturedImage : UIImage = UIImage()
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
        discardNew("Discard Listing", subTitle: "Listing will be discarded")
    }
    
    @IBAction func nextClicked(sender: UIButton) {
        view.endEditing(true)
        checkFields()
    }
    
    
    
    //Load UI
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        if NSUserDefaults.standardUserDefaults().stringForKey("posted") == "true"{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("false", forKey: "posted")
            viewDidLoad()
            
        }
        
    }
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        defaultLabelColor = requiredCharacterFields.textColor
        defaultColor = titleField.textColor!
        defaultBorderColor = titleField.backgroundColor!
        titleField.layer.borderColor = defaultBorderColor.CGColor
        priceField.layer.borderColor = defaultBorderColor.CGColor
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
        priceField.delegate = self
        titleField.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        priceField.addTarget(self, action: #selector(self.textViewDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        
        if previousScreen == "EditView"{
            titleField.text = editedTitle
            priceField.text = editedPrice
            screenTitle.text = "Edit About"
            previewImage.image = decodedPreviewImage
        } else {
            screenTitle.text = "About"
            titleField.text = ""
            priceField.text = ""
            previewImage.image = UIImage(named: "NoImageSelected")
        }
        
    }
    
    //Next text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === titleField) {
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
       /*
            if textField === titleField && titleField.text?.characters.count > 6{
                requiredCharacterFields.textColor = defaultLabelColor
                requiredCharacterFields.text = "Short description 6-24 Characters"
            } else if textField === titleField && titleField.text?.characters.count < 6{
                setError(titleField)
                requiredCharacterFields.textColor = hexStringToUIColor("#f27163")
                requiredCharacterFields.text = "Title to short"
            } else if textField === titleField && titleField.text?.characters.count > 24{
                requiredCharacterFields.textColor = hexStringToUIColor("#f27163")
                requiredCharacterFields.text = "Title to long"
        }
         */
        
        
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
        DataService.dataService.CURRENT_USER_REF.observeEventType(.Value, withBlock: { snapshot in
            let currentUser = snapshot.value!.objectForKey("username") as! String
            self.currentUsername = currentUser
            }, withCancelBlock: { error in
        })
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
    
    
    func removeListing(){
        titleField.text = ""
        priceField.text = ""
        previewImage.image = UIImage(named: "NoImageSelected")
        if previousScreen == "EditView"{
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            performSegueWithIdentifier("MainSegue", sender: self)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    //Check Fields
    func checkFields(){
        if titleField.text == "" || self.titleField.text?.characters.count < 6 {
            errorInvalid("Missing Fields", subTitle: "Please fill in both fields")
        } else {
        performSegueWithIdentifier("locationSegue", sender: self)
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        /*if textView == priceField {
            if ((priceField.text?.characters.contains("$")) != nil && priceField.text != ""){
                let wholeString = priceField.text!
                let newString = wholeString.stringByReplacingOccurrencesOfString("$", withString: "")
               
                if Int(newString) == nil{
                    setError(priceField)
                    priceField.becomeFirstResponder()
                } 
            }
        } else {
 
            titleField.layer.borderColor = defaultBorderColor.CGColor
            requiredCharacterFields.textColor = defaultLabelColor
            requiredCharacterFields.text = "Short description 6-24 Characters"
            
        }
        */
        textView.layer.borderColor = defaultBorderColor.CGColor
        textView.textColor = defaultColor
    }
    
    //Sends data to next view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIApplication.sharedApplication().statusBarHidden = false
        
        if segue.identifier == "locationSegue"{
            if previousScreen == "EditView"{
                let listingLocation : ListingLocation = segue.destinationViewController as! ListingLocation
                listingLocation.editType = editedType
                listingLocation.previousScreen = "EditView"
                listingLocation.pickedImage = previewImage.image!
                listingLocation.pickedTitle = titleField.text!
                listingLocation.pickedLocation = editedLocation!
                listingLocation.editProfileImg = editedProfileImg!
                listingLocation.editPhoto = previewImage.image!
                listingLocation.editUser = editedUser!
                listingLocation.editDetails = editedDetails!
                listingLocation.editKey = editKey
                listingLocation.pickedPrice = priceField.text!
            } else {
                let listingLocation : ListingLocation = segue.destinationViewController as! ListingLocation
                listingLocation.pickedImage = previewImage.image!
                listingLocation.pickedTitle = titleField.text!
                if priceField.text == ""{
                    listingLocation.pickedPrice = priceField.placeholder!
                } else {
                    if !(priceField.text?.characters.contains("$"))!{
                        listingLocation.pickedPrice = "$\(priceField.text!)"
                    } else {
                        listingLocation.pickedPrice = priceField.text!
                    }
                }

            }
        }
        
    }
    
    func updatePosts(){
        DataService.dataService.POST_REF.child(editKey).observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.postForEdit = []
            
            
            if snapshot.children.allObjects is [FIRDataSnapshot] {
                
                
                if let postDictionary = snapshot.value as? Dictionary<String, AnyObject> {
                    let key = snapshot.key
                    let post = Post(key: key, dictionary: postDictionary)
                    self.postForEdit.insert(post, atIndex: 0)
                    self.setVariables()
                    self.loadUI()
                } else {
                    //self.navigationController?.popViewControllerAnimated(true)
                }
            }
            
        })
    }
    
    //Show alert view
    func loginErrorAlert(title: String, message: String) {
        let alert = JSSAlertView().show(self, title: title, text: message)
        alert.addAction(setFirstResponder)
    }
    
    func setFirstResponder(){
        if errorMessage == "Email"{
            titleField.becomeFirstResponder()
            setError(titleField)
        } else {
            priceField.becomeFirstResponder()
            setError(priceField)
        }
    }
    
    func errorInvalid(title : String, subTitle : String){
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.addButton("Done") {
            if Int(self.priceField.text!) == nil{
                self.setError(self.priceField)
                self.priceField.becomeFirstResponder()
            }
            if self.titleField.text == "" || self.titleField.text?.characters.count < 7 {
                self.setError(self.titleField)
                self.titleField.becomeFirstResponder()
            }
        }
        alertView.showError(title, subTitle: subTitle)
    }
    
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

    
    func setError(textField : UITextField){
        textField.layer.borderColor = hexStringToUIColor("#f27163").CGColor
        textField.layer.cornerRadius = 10.0
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
    }
    
    func clearUI(){
        previewImage.image = UIImage(named: "NoImageSelected")
    }
    
}
