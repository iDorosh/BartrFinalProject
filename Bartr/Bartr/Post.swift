//
//  Post.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postRef: Firebase!
    
    //Post Information
    private var _postKey: String!
    private var _postText: String!
    private var _postviews: Int!
    private var _username: String!
    private var _postTitle: String!
    private var _postLocation: String!
    private var _postType: String!
    private var _postImage: String!
    private var _postUserImg: String!
    private var _postDate: String!
    private var _postPrice: String!
    
    //Information Getters
    var postKey: String {
        return _postKey
    }
    
    var postText: String {
        return _postText
    }
    
    var postTitle: String {
        return _postTitle
    }
    
    var postLocation: String {
        return _postLocation
    }
    
    var postType: String {
        return _postType
    }
    
    var postImage: String {
        return _postImage
    }
    
    var postviews: Int {
        return _postviews
    }
    
    var username: String {
        return _username
    }
    
    var postUserImage : String {
        return _postUserImg
    }
    
    var postDate : String {
        return _postDate
    }
    
    var postPrice : String {
        return _postPrice
    }
    
    // Initialize the new post
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = key
        
        // Within the post, or Key, the following properties are children
        
        if let views = dictionary["views"] as? Int {
            self._postviews = views
        }
        
        if let post = dictionary["postText"] as? String {
            self._postText = post
        }
        
        if let postT = dictionary["postTitle"] as? String {
            self._postTitle = postT
        }
        
        if let postL = dictionary["postLocation"] as? String {
            self._postLocation = postL
        }
        
        if let postTY = dictionary["postType"] as? String {
            self._postType = postTY
        }
        
        if let postI = dictionary["postImage"] as? String {
            self._postImage = postI
        }
        
        if let postPI = dictionary["userProfileImg"] as? String {
            self._postUserImg = postPI
        }
        
        if let postD = dictionary["postDate"] as? String {
            self._postDate = postD
        }
        
        if let postP = dictionary["postPrice"] as? String {
            self._postPrice = postP
        }
        
        if let user = dictionary["author"] as? String {
            self._username = user
        } else {
            self._username = ""
        }
        
        // The above properties are assigned to their key.
        self._postRef = DataService.dataService.POST_REF.childByAppendingPath(self._postKey)
    }
}