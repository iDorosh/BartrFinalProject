//
//  UsersRecentFeedBackCell.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
class UsersRecentFeedBackCell: UITableViewCell {
    
    var feedback : FeedbackObject!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var post: UILabel!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var rating: FloatRatingView!
    
    @IBOutlet weak var ratinglabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Creating table view cells
    func tableConfig(selectedFeedback : FeedbackObject){
        feedback = selectedFeedback
        
        profileImage.image = decodeString(feedback.feedbackImage)
        userName.text = feedback.feedbackUser
        post.text = feedback.feedbackTitle
        
        let dateString : String = feedback.feedbackDate
        
        let date = dateFormatter().dateFromString(dateString)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        
        timeStamp.text = elapsedTime(seconds)
        
        if Float(feedback.feedbackRating) > 1 {
            ratinglabel.text = "\(feedback.feedbackRating) stars"
        } else {
            ratinglabel.text = "\(feedback.feedbackRating) star"
        }
        
        rating.rating = Float(feedback.feedbackRating)!
    }
    
}