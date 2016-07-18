//
//  CustomChatTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/13/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class CustomChatTableCell: UITableViewCell {
    
    
    //Outlets
    @IBOutlet weak var newIndicator: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var post: UILabel!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    var imgString : String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //Creating table view cells  "users\(withUserId)"
    func tableConfig(recent : NSDictionary){

        //let withUserId = (recent.objectForKey("withUserUserId") as? String)!
        let withUsername = (recent.objectForKey("withUserUsername") as? String)!
        let listingTitle = (recent.objectForKey("listingTitle") as? String)!
        let dateString = (recent.objectForKey("date") as? String)!
        let pImg : String = (recent.objectForKey("usersProfileImage") as? String)!
        userName.text = withUsername
        
        
        let decodedData2 = NSData(base64EncodedString: pImg, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedimage2 = UIImage(data: decodedData2!)
        
        profileImage.image = decodedimage2! as UIImage
 
        
        post.text = listingTitle
        let date = dateFormatter().dateFromString(dateString)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        
        timeStamp.text = elapsedTime(seconds)
        
           }
    
    }
