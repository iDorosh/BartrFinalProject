//
//  CustomTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class CustomTableCell: UITableViewCell {

    //Data
    var post: Post!
    var voteRef: Firebase!
    
    //Table Cell Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(post: Post) {
        //Set post to current post being created
        self.post = post
    
        // Set the labels and textView.
        self.user.text = post.username
        self.title.text = post.postTitle
        self.location.text = "\(post.postLocation)"
        self.type.text = post.postType
        self.views.text = "Views: \(post.postviews)"
        self.timeStamp.text = post.postDate
        self.price.text = post.postPrice
        
        //Images for user profile and listing image
        decodeImages()
    }
    
    //Decodes images from a Base64String stored in Firebase
    func decodeImages(){
        let decodedData = NSData(base64EncodedString: post.postImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedimage = UIImage(data: decodedData!)
        
        mainImage.image = decodedimage! as UIImage
        
        let decodedData2 = NSData(base64EncodedString: post.postUserImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedimage2 = UIImage(data: decodedData2!)
        
        profileImg.image = decodedimage2! as UIImage
    }

}
