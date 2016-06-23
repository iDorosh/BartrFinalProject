//
//  Details.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/14/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class Details: UIViewController, UITextViewDelegate {
    
    @IBAction func backToDetails(segue: UIStoryboardSegue){}
    
    //Variables
    var pickedImage: UIImage = UIImage()
    var pickedTitle : String = String()
    var pickedLocation : String = String()
    var type : [String] = []
    var Unchecked : UIImage = UIImage(named: "NotChecked")!
    var Checked : UIImage = UIImage(named: "Checked")!
    var typesString : String = String()
    var pickedPrice : String = String()
    
    var previousScreen : String = String()
    var editTitle : String = String()
    var editPrice : String = String()
    var editLocation : String = String()
    var editPhoto : UIImage = UIImage()
    var editType : String = String()
    var editProfileImg : String = String()
    var editUser : String = String()
    var editDetails : String = String()
    var editKey : String = String()
    
    
    //Outlets
    @IBOutlet weak var Image1: UIImageView!
    @IBOutlet weak var Image2: UIImageView!
    @IBOutlet weak var Image3: UIImageView!
    @IBOutlet weak var Image4: UIImageView!
    @IBOutlet weak var pickedDescription: UITextView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var backBttn: UIButton!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    
    
    //Actions
    @IBAction func forSale(sender: UIButton) {
        checkedChecker(Image1, listingType: "Sale")
    }
    
    @IBAction func forTrade(sender: UIButton) {
        checkedChecker(Image2, listingType: "Trade")
    }
    
    @IBAction func lookingFor(sender: UIButton) {
        checkedChecker(Image3, listingType: "Looking")
    }
    
    @IBAction func free(sender: UIButton) {
        checkedChecker(Image4, listingType: "Free")
    }
    
    @IBAction func backBttnAction(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func discardListing(sender: UIButton) {
        showAlertView("Discard Listing", text: "Listing will be discarded", confirmButton: "Discard", cancelButton: "Cancel")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyBlurrEffect()
        addTapRecognizer()
        pickedDescription.delegate = self
        if previousScreen == "EditView"{
            if ((editType.containsString("Sale"))){
                Image1.image = Checked
                type.append("Sale")
            }
            if ((editType.containsString("Trade"))){
                Image2.image = Checked
                type.append("Trade")
            }
            if ((editType.containsString("Looking"))){
                Image3.image = Checked
                type.append("Looking")
            }
            if ((editType.containsString("Free"))){
                Image4.image = Checked
                type.append("Free")
            }
            print(editDetails)
            pickedDescription.text = editDetails

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Tap Recognizer to minimize the keyboard
    func addTapRecognizer(){
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Camera.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Checks and Unchecks type boxes
    func checkedChecker(image: UIImageView, listingType: String) {
        if image.image == Unchecked{
            image.image = Checked
            type.append(listingType)
        } else {
            image.image = Unchecked
            type.removeAtIndex(type.indexOf(listingType)!)
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
        performSegueWithIdentifier("MainSegue", sender: self)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        UIApplication.sharedApplication().statusBarHidden = true
        detailsScrollView.setContentOffset(CGPointMake(0,210), animated: true)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Resets view offset
        detailsScrollView.setContentOffset(CGPointMake(0,0), animated: true)
        view.endEditing(true)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        detailsScrollView.setContentOffset(CGPointMake(0,0), animated: true)
    }
    
    //Applies Blurr effect to the background image
    func applyBlurrEffect(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.previewImage.addSubview(blurEffectView)
    }
    
    //Creates the type string to be passed into the next view
    func createTypeString(){
        typesString = ""
        for types in type {
            if type.indexOf(types) == 0 {
                typesString = typesString + types
            } else {
                typesString = typesString + ", \(types)"
            }
        }
    }

    //Sends data to the Summary Page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        createTypeString()
        
        detailsScrollView.setContentOffset(CGPointMake(0,0), animated: true)
        
        if (segue.identifier == "summarySegue"){
            let summary : Summary = segue.destinationViewController as! Summary
            summary.pickedImage = pickedImage
            summary.pickedTitle = pickedTitle
            summary.pickedLocation = pickedLocation
            summary.pickedTypes = typesString
            summary.pickedDescription = pickedDescription.text
            summary.pickedPrice = pickedPrice
            summary.editKey = editKey
            if (previousScreen == "EditView"){
                summary.previousVC = "EditView"
            }
        }
    }
}
