//
//  Feedback.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class Feedback: UIViewController {
    
    var allOffers = [Offers]()
    var selectedOffers = [Offers]()
    var viewOffer : Offers!
    
    var postKey : String = String()
    var previousSegue : String = String()
    var selectedTitle : String = String()
    var selectedImage : String = String()
    var uid : String = String()
    
   
    @IBAction func backButton(sender: UIButton) {
        if previousSegue == "Profile"{
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
            performSegueWithIdentifier("backToEditProfileSegue", sender: self)
        }
    }
    
    @IBAction func sendFeedBack(sender: UIButton) {
        let selectedPostRef = DataService.dataService.POST_REF.child(postKey)
        selectedPostRef.removeValue()
        performSegueWithIdentifier("BackToProfile", sender: self)
    }
 
    
    //Back to Chat Action
    @IBAction func backToFeedback(segue: UIStoryboardSegue){}
    
    //Table View
    @IBOutlet weak var tabletView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        observeOffers()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedOffers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let offer = selectedOffers[indexPath.row]
        let cell : FeedbackTableCell = tableView.dequeueReusableCellWithIdentifier("FeedbackCell")! as! FeedbackTableCell
        
        cell.tableConfig(offer)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        viewOffer = selectedOffers[indexPath.row]
        performSegueWithIdentifier("ViewOfferSegue", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func observeOffers() {
        DataService.dataService.CURRENT_USER_REF.child("offers").observeEventType(.Value, withBlock: { snapshot in
            // 3
            self.allOffers = []
            self.selectedOffers = []
            
        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots{
                    
                    if let offersDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let offer = Offers(key: key, dictionary: offersDictionary)
                        self.allOffers.insert(offer, atIndex: 0)
                    }
                }
            
            for offers in self.allOffers{
                if offers.offerTitle == self.selectedTitle{
                    self.selectedOffers.append(offers)
                }
            }
            }
            self.tabletView.reloadData()
        })
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewOfferSegue"){
            let offer : ViewOffers = segue.destinationViewController as! ViewOffers
            offer.offer = viewOffer
            offer.uid = viewOffer.offerUID
            offer.postKey = viewOffer.listingKey
            offer.sentOffer = false
          
        }

    }
    
}
