//
//  FeedbackTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import FirebaseAuth

class FeedbackTableCell: UITableViewCell {
    
    var allOffers: Offers!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var offerText: UILabel!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet var status: UILabel!
    
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Creating table view cells
    func tableConfig(offer : Offers){
        allOffers = offer
        
        

        if offer.offerUID != FIRAuth.auth()?.currentUser!.uid{
            userName.text = offer.offerUser
            profileImage.image = decodeString(offer.offerProfileImage)
        } else {
            userName.text = offer.recieverUsername
            profileImage.image = decodeString(offer.recieverImage)
        }
        offerText.text = offer.offerText
        title.text = offer.offerTitle
        if offer.offerUID == FIRAuth.auth()?.currentUser?.uid {
            status.text = offer.offerStatus
        } else {
            if offer.offerStatus == "Read" || offer.offerStatus == "Accepted" || offer.offerStatus == "Feedback Left"{
                status.text = offer.offerStatus
            } else if offer.offerStatus == "Delivered" {
                status.text = "New Offer"
            } else if offer.offerStatus == "Canceled"{
                status.text = "Offer Canceled"
            } else {
                 status.text = "Read"
            }
        }
        
        
        
        let dateString : String = offer.offerDate
        
        let date = dateFormatter().dateFromString(dateString)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        
        timeStamp.text = elapsedTime(seconds)
    }
    
    func decodeString(img : String) -> UIImage{
        let decodedData = NSData(base64EncodedString: img, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedimage = UIImage(data: decodedData!)
        
        return decodedimage! as UIImage
    }
    
    
}