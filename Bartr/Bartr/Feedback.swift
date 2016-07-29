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
    
//Variables
    //Data
    var allOffers = [Offers]()
    var selectedOffers = [Offers]()
    var viewOffer : Offers!
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Strings
    var postKey : String = String()
    var previousSegue : String = String()
    var selectedTitle : String = String()
    var selectedImage : String = String()
    var uid : String = String()
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
   
//Outlets
    @IBOutlet weak var tabletView: UITableView!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
 
//Actions
    //Back to Chat Action
    @IBAction func backToFeedback(segue: UIStoryboardSegue){}
    
    @IBAction func backButton(sender: UIButton) {
        if previousSegue == "Profile"{
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
            performSegueWithIdentifier("backToEditProfileSegue", sender: self)
        }
    }
    
    //Send Feedback
    @IBAction func sendFeedBack(sender: UIButton) {
        let selectedPostRef = DataService.dataService.POST_REF.child(postKey)
        selectedPostRef.removeValue()
        performSegueWithIdentifier("BackToProfile", sender: self)
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

//UI
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeOffers()
    }
 
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

//Functions
    //Table View
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
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Firebase
    
        //Get current Offers
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
    

    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Send data to the next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewOfferSegue"){
            let offer : ViewOffers = segue.destinationViewController as! ViewOffers
            offer.offer = viewOffer
            offer.uid = viewOffer.offerUID
            offer.postKey = viewOffer.listingKey
            offer.sentOffer = false
          
        }

    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
}
