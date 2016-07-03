//
//  FeedbackTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class FeedbackTableCell: UITableViewCell {
    
    var allOffers: Offers!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var offerText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Creating table view cells
    func tableConfig(offer : Offers){
        allOffers = offer
        let decodedData = NSData(base64EncodedString: offer.offerProfileImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedimage = UIImage(data: decodedData!)
        
        profileImage.image = decodedimage! as UIImage

        userName.text = offer.offerUser
        offerText.text = offer.offerText
    }
    
}