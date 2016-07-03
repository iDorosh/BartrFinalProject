//
//  Post.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import Foundation
import Firebase

class Offers {
    private var _offerRef: Firebase!
    
    //Post Information
    private var _offerKey: String!
    private var _offerUser: String!
    private var _offerTitle: String!
    private var _offerText: String!
    private var _offerChecked: Bool!
    private var _offerProfileImage: String!
  
    
    //Information Getters
    var offerKey: String {
        return _offerKey
    }
    
    var offerUser: String {
        return _offerUser
    }
    
    var offerTitle: String {
        return _offerTitle
    }
    
    var offerText: String {
        return _offerText
    }
    
    var offerChecked: Bool {
        return _offerChecked
    }
    
    var offerProfileImage: String {
        return _offerProfileImage
    }
    
    // Initialize the new offer
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._offerKey = key
        
        // Within the post, or Key, the following properties are children
        
        if let offerU = dictionary["senderUsername"] as? String {
            self._offerUser = offerU
        }
        
        if let offerT = dictionary["listingTitle"] as? String {
            self._offerTitle = offerT
        }
        
        if let offerD = dictionary["offerText"] as? String {
            self._offerText = offerD
        }
        
        if let offerC = dictionary["offerChecked"] as? Bool {
            self._offerChecked = offerC
        }
        
        if let offerP = dictionary["currentProfileImage"] as? String {
            self._offerProfileImage = offerP
        }
        
        // The above properties are assigned to their key.
        self._offerRef = sendOfferRef
    }
}