//
//  ViewOffers.swift
//  Bartr
//
//  Created by Ian Dorosh on 7/2/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class ViewOffers: UIViewController {
    var offer : Offers!
    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerUser: UILabel!
    @IBOutlet weak var offerText: UITextView!
    
    var offerImageString : String = String()
    var offerUserString : String = String()
    var offerTextString : String = String()
    
    

    @IBOutlet weak var rating: FloatRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        rating.rating = 5.0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        offerImageString = offer.offerProfileImage
        offerUserString = offer.offerUser
        offerTextString = offer.offerText
        
        offerImage.image = UIImage(named: "placeholderImg")
    }
    
}
