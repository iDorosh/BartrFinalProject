//
//  CustomChatTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/13/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class CustomChatTableCell: UITableViewCell {
    
    //Place holder information for chat threads
    var userNames : [String] = ["Mac>Windows", "Sell24/7", "Mac4Lyfe"]
    var listing : [String] = ["MacBook Pro 15in (Late 2013)", "Physics 101 TextBook", "Dinning Table with 6 Chairs"]
    var images : [String] = ["Image1", "Image2", "Image3"]
    var new : [String] = ["yes", "no", "no"]
    var timeStamps : [String] = ["5:14 PM", "10:20 AM", "Yesterday"]
    
    //Outlets
    @IBOutlet weak var newIndicator: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var post: UILabel!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Creating table view cells
    func tableConfig(index : Int){
        if new[index] == "yes"{
        newIndicator.image = UIImage(named: "New")
        } else {
            newIndicator.image = UIImage(named: "NotNew")
        }
        
        profileImage.image = UIImage(named: images[index])
        userName.text = userNames[index]
        post.text = listing[index]
        timeStamp.text = timeStamps[index]
    }
}
