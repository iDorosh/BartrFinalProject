//
//  BlockedUsersTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/22/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class BlockedUsersTableCell: UITableViewCell {

//Variables
     var blocked: BloackedUsersObject!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

//Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Creating table view cells
    func tableConfig(blocked : BloackedUsersObject){
        //Setting blocked object
        self.blocked = blocked
        
        //Setting image to blocked users image and username to blocked users name
        profileImage.image = decodeString(blocked.blockedUserImage)
        userName.text = blocked.blockedUser
        
        //Seting time stamp from when the user has been blocked
        let date = dateFormatter().dateFromString(blocked.date)
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
