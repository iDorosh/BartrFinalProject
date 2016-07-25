//
//  ViewOffers.swift
//  Bartr
//
//  Created by Ian Dorosh on 7/2/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import FirebaseDatabase

class ViewOffers: UIViewController {
    var offer : Offers!
    var uid : String = String()
    var itemRef : FIRDatabaseReference!
    var postKey : String?
    var previousProfile : Bool = false
    var sentOffer : Bool = false
    var offerComplete : Bool = false
    
    @IBOutlet weak var deleteOffer: UIButton!
    
    @IBAction func deleteOfferAction(sender: UIButton) {
        deleteCompletedOffer()
    }
    
    @IBOutlet weak var offerRatingView: FloatRatingView!
    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerUser: UILabel!
    @IBOutlet weak var offerText: UITextView!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var offerTitle: UILabel!
    
    var offerImageString : String = String()
    var offerUserString : String = String()
    var offerTextString : String = String()
    var offerKey : String = String()
    var offerRating : Float = Float()
    var accepted = false
    var allOffers = [Offers]()
    
    @IBOutlet weak var acceptBttn: UIButton!
    @IBOutlet weak var declineBttn: UIButton!
    @IBOutlet weak var cancelBttn: UIButton!
    @IBOutlet weak var messageBttn: UIButton!
    
    

    @IBOutlet weak var rating: FloatRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backClicked(sender: UIButton) {
        back()
    }
    
    
    func offerViewed(){
        let selectedPostRef2 = DataService.dataService.CURRENT_USER_REF.child("offers").child(offerKey)
        selectedPostRef2.updateChildValues([
            "offerChecked": "true",
            "offerStatus" : "Read",
            ])
        
        let selectedPostRef = DataService.dataService.USER_REF.child(uid).child("offers").child(offerKey)
        selectedPostRef.updateChildValues([
            "offerChecked": "true",
            "offerStatus" : "Read",
            ])

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        if (sentOffer) {
            acceptBttn.hidden = true
            declineBttn.hidden = true
            messageBttn.hidden = true
            cancelBttn.hidden = false
            deleteOffer.hidden = true
        }
        
        if offerComplete {
            acceptBttn.hidden = true
            declineBttn.hidden = true
            messageBttn.hidden = true
            cancelBttn.hidden = true
            deleteOffer.hidden = false
        }
        rating.rating = 5.0
        offerImageString = offer.offerProfileImage
        offerUserString = offer.offerUser
        offerTextString = offer.offerText
        offerKey = offer.offerKey
        offerRating = Float(offer.offerRating)!
        
        
        offerImage.image = decodeString(offerImageString)
        offerUser.text = offerUserString
        offerText.text = offerTextString
        offerTitle.text = offer.offerTitle
        offerText.font = UIFont(name: "Avenir", size: 15)
        offerRatingView.rating = offerRating
        
        if !sentOffer {
            offerViewed()
        }
        
        
        let fixedWidth = offerText.frame.size.width
        offerText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = offerText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = offerText.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height+10)
        offerText.frame = newFrame;
        
        let fixedWidth2 = offerView.frame.size.width
        offerView.sizeThatFits(CGSize(width: fixedWidth2, height: CGFloat.max))
        let newSize2 = offerView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame2 = offerView.frame
        newFrame2.size = CGSize(width: max(newSize2.width, fixedWidth2), height: newSize.height + 30)
        offerView.frame = newFrame2;
        
        acceptBttn.frame.origin = CGPointMake(acceptBttn.frame.origin.x, newSize.height + 260)
        
        declineBttn.frame.origin = CGPointMake(declineBttn.frame.origin.x, newSize.height + 260)
        
        cancelBttn.frame.origin = CGPointMake(cancelBttn.frame.origin.x, newSize.height + 260)
    }
    
    @IBAction func newMessage(sender: UIButton) {
        performSegueWithIdentifier("NewMessage", sender: self)
    }
    
    @IBAction func acceptOffer(sender: UIButton) {
        self.sendAccepted()
    }

    @IBAction func declineOffer(sender: UIButton) {

        self.backToOffer()
    }
    
    @IBAction func cancelOffer(sender: UIButton) {
        cancelOffer()
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewMessage"{
            
            let chatVc : ChatViewController = segue.destinationViewController as! ChatViewController
            chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
            chatVc.recieverUsername = offerUserString
            chatVc.recieverUID = offer.offerUID
            chatVc.ref4 = ref
            chatVc.selectedTitle = offer.offerTitle
            chatVc.selectedImage = offerImageString
            chatVc.selectedUser = offerUserString
            chatVc.currentUser = currentUser
            chatVc.senderUID = uid
            chatVc.title = offerUserString
            chatVc.avatar = offerImageString
            chatVc.previousScreen = "accepted"
            chatVc.accepted = accepted
            
            
        }

        
    }
    
    //OfferAccepted
    func success(){
        let selectedPostRef = DataService.dataService.CURRENT_USER_REF.child("offers").child(offerKey)
        selectedPostRef.updateChildValues([
            "offerAccepted": "true",
            "offerDeclined": "false",
            "offerStatus" : "Accepted",
            ])
        
        let selectedPostRef2 = DataService.dataService.USER_REF.child(uid).child("offers").child(offerKey)
        selectedPostRef2.updateChildValues([
            "offerAccepted": "true",
            "offerDeclined": "false",
            "offerStatus" : "Accepted",
            ])
        
        let selectedPostRef3 = DataService.dataService.POST_REF.child(postKey!)
        selectedPostRef3.updateChildValues([
            "postComplete": true,
            ])

        let alertView = SCLAlertView()
        alertView.addButton("Message User", target: self, selector: #selector(messageUser))
        alertView.addButton("Done", target: self, selector: #selector(backToListing))
        alertView.showCloseButton = false
        alertView.showSuccess("Offer Accepted", subTitle: "You can send a user more information on a meeting location")
    }
    
    func cancelOffer(){
        
        let selectedPostRef = DataService.dataService.CURRENT_USER_REF.child("offers").child(offerKey)
        selectedPostRef.updateChildValues([
            "offerStatus" : "Canceled",
            ])
        
        let selectedPostRef2 = DataService.dataService.USER_REF.child(uid).child("offers").child(offerKey)
        selectedPostRef2.updateChildValues([
            "offerStatus" : "Canceled",
            ])
        
        let alertView = SCLAlertView()
        alertView.addButton("Done", target: self, selector: #selector(backToListing))
        alertView.showCloseButton = false
        alertView.showSuccess("Offer Accepted", subTitle: "You can send a user more information on a meeting location")
    }
    
    //OfferAccepted
    func sendAccepted(){
        let alertView = SCLAlertView()
        alertView.addButton("Accept", target: self, selector: #selector(success))
        alertView.addButton("Cancel", target: self, selector: #selector(back))
        alertView.showCloseButton = false
        alertView.showWarning("Accept Offer?", subTitle: "Are you sure you want to accept this offer? It cannot be undone.")
    }
    
    //OfferAccepted
    func backToOfferListing(){
        let alertView = SCLAlertView()
        alertView.showSuccess("Offer Accepted", subTitle: "Once the transaction is complete please come back to your post to leave the user feedback")
    }
    
    //OfferAccepted
    func backToOffer(){
        let alertView = SCLAlertView()
        alertView.addButton("Decline", target: self, selector: #selector(removeOffer))
        alertView.addButton("Cancel", target: self, selector: #selector(back))
        alertView.showCloseButton = false
        alertView.showSuccess("Decline Offer", subTitle: "Are you sure you want to decline this offer?")
    }
    
    func back(){
        if previousProfile {
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
            performSegueWithIdentifier("BackToOffersThread", sender: self)
        }
    }
    
    func removeOffer(){
        let updateRef = DataService.dataService.USER_REF.child("\(offer.offerUID)").child("offers").child("\(offer.offerKey)")
        
        updateRef.updateChildValues([
            "offerStatus" : "Declined",
            "offerDeclined" : "true"
            ])
        
        let updateRef2 = DataService.dataService.CURRENT_USER_REF.child("offers").child(offerKey)
        updateRef2.updateChildValues([
            "offerStatus" : "Declined",
            "offerDeclined" : "true"
            ])


        if previousProfile {
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
        performSegueWithIdentifier("BackToOffersThread", sender: self)
        }
    }
    
    func backToListing(){
        backToOfferListing()
        if previousProfile {
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
        performSegueWithIdentifier("OfferAccepted", sender: self)
        }
    }
    func messageUser(){
        let alertView = SCLAlertView()
        alertView.showSuccess("Offer Accepted", subTitle: "Once the transaction is complete please come back to your post to leave the user feedback")
        accepted = true
        performSegueWithIdentifier("NewMessage", sender: self)
    }
    
    func deleteCompletedOffer(){
        if !sentOffer {
        if (offer.offerDeclined == "false") {
            if offer.feedbackLeft == "false" {
                let updateRef = DataService.dataService.USER_REF.child("\(offer.offerUID)").child("offers").child("\(offerKey)")
                updateRef.updateChildValues([
                    "offerStatus" : "Declined",
                    "offerDeclined" : "true"
                    ])
            }
            let deleteRef = DataService.dataService.CURRENT_USER_REF.child("offers").child("\(offerKey)")
            deleteRef.removeValue()
        }
        
        let deleteRef = DataService.dataService.CURRENT_USER_REF.child("offers").child("\(offer.offerKey)")
        
        deleteRef.removeValue()
    } else if sentOffer {
    if (offer.offerDeclined == "false") {
        if offer.offerAccepted == "false" {
            let updateRef = DataService.dataService.USER_REF.child("\(offer.offerUID)").child("offers").child("\(offerKey)")
            updateRef.updateChildValues([
            "offerStatus" : "Canceled",
            "offerDeclined" : "true"
            ])
        }
        let deleteRef = DataService.dataService.CURRENT_USER_REF.child("offers").child("\(offer.offerKey)")
        deleteRef.removeValue()
    }
    
    
    }

        performSegueWithIdentifier("BackToProfile", sender: self)
    }

}
