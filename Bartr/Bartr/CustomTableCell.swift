//
//  CustomTableCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CustomTableCell: UITableViewCell {

    //Data
    var post: Post!
    var voteRef: FIRDatabaseReference!
    
    
    @IBOutlet weak var ratingView: FloatRatingView!
    
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
    
    @IBOutlet weak var bartrCompleteImg: UILabel!
    
    
   @IBOutlet weak var expirationDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(post: Post) {
        //Set post to current post being created
        self.post = post
        self.price.text = post.postPrice
    
        // Set the labels and textView.
        self.user.text = post.username
        self.title.text = post.postTitle
        self.location.text = "\(post.postLocation)"
        self.type.text = post.postType
        
        let totalViews : Int = post.postviews
        var viewsOrView : String = "View"
        if (totalViews > 1){
            viewsOrView = "Views"
            self.views.text = "\(totalViews) \(viewsOrView)"
        } else if totalViews == 0 {
            self.views.text = "No Views"
        } else {
            self.views.text = "\(totalViews) \(viewsOrView)"
        }
        
        expirationDate.text = getExperationDate(post.expireDate)
        
        let dateString : String = post.postDate
        
        let date = dateFormatter().dateFromString(dateString)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        
        timeStamp.text = elapsedTime(seconds)
        
        //Images for user profile and listing image
        decodeImages()
        
        if post.postComplete{
            bartrCompleteImg.hidden = false
        } else {
            bartrCompleteImg.hidden = true
        }
        
        updateFeedback(post.username)
    }
    
    func updateFeedback(userName : String){
        DataService.dataService.USER_REF.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    let test = snap.value!.objectForKey("username") as! String
                    if (test == userName){
                        self.ratingView.rating = Float(snap.value!.objectForKey("rating") as! String)!
                    }
                }
            }
            
        })
        
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


