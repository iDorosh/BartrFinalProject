//
//  DataService.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//


import Foundation
import Firebase

class DataService {
    static let dataService = DataService()
    
    //References for Databases, Users and Posts
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    private var _USER_REF = Firebase(url: "\(BASE_URL)/users")
    private var _POST_REF = Firebase(url: "\(BASE_URL)/posts")
   
    //Reference Getters
    var BASE_REF: Firebase {
        return _BASE_REF
    }
    
    var USER_REF: Firebase {
        return _USER_REF
    }

    var POST_REF: Firebase {
        return _POST_REF
    }
    
    //Gets current user
    var CURRENT_USER_REF: Firebase {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        let currentUser = Firebase(url: "\(BASE_REF)").childByAppendingPath("users").childByAppendingPath(userID)
        return currentUser!
    }
    
    //Creates new user account triggered by register screen
    func createNewAccount(uid: String, user: Dictionary<String, String>) {
        USER_REF.childByAppendingPath(uid).setValue(user)
    }
    
    //Creates a new post from information in the Summary.swift file
    func createNewPost(post: Dictionary<String, AnyObject>) {
        let firebaseNewPost = POST_REF.childByAutoId()
        firebaseNewPost.setValue(post)
    }
    
    func createNewOffer(offer: Dictionary<String, AnyObject>) {
        let firebaseNewPost = sendOfferRef
        firebaseNewPost.setValue(offer)
    }
    
}