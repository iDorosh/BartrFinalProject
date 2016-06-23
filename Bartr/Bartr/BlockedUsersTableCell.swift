//
//  BlockedUsersTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/22/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class BlockedUsersTableCell: UITableViewCell {

    //Place holder information for chat threads
    var userNames : [String] = ["Mac>Windows", "Sell24/7", "Mac4Lyfe"]
    var listing : [String] = ["MacBook Pro 15in (Late 2013)", "Physics 101 TextBook", "Dinning Table with 6 Chairs"]
    var images : [String] = ["Image1", "Image2", "Image3"]
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var post: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Creating table view cells
    func tableConfig(index : Int){
        profileImage.image = UIImage(named: images[index])
        userName.text = userNames[index]
        post.text = listing[index]
    }

}
