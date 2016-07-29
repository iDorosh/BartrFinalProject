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
    
 //Variables 
    var imgString : String = ""
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Outlets
    @IBOutlet weak var newIndicator: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Creating table view cells  "users\(withUserId)"
    func tableConfig(recent : NSDictionary){

        //Setting thread details
        let withUsername = (recent.objectForKey("withUserUsername") as? String)!
        let listingTitle = (recent.objectForKey("lastMessage") as? String)!
        let dateString = (recent.objectForKey("date") as? String)!
        let pImg : String = (recent.objectForKey("usersProfileImage") as? String)!
        
        userName.text = withUsername
        profileImage.image = decodeString(pImg)
        post.text = listingTitle
        
        //Setting timestamp
        let date = dateFormatter().dateFromString(dateString)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        timeStamp.text = elapsedTime(seconds)
        
    }
    
        override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        override func setSelected(selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
}
