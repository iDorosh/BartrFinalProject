//
//  Constants.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import Foundation
import Firebase

//Data Base reference
let BASE_URL = "https://vulkanbartr.firebaseio.com"

var sendOfferRef = Firebase()

var currentUserUID : String = ""
var senderUserUID : String = ""
var currentUser : String = ""
var currentProfileImg : String = ""

private let dateFormat = "yyyyMMddHHmmss"
var ref = Firebase(url: BASE_URL)

func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}

func getUserInfo(){
    DataService.dataService.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
        currentUser = snapshot.value.objectForKey("username") as! String
        currentProfileImg = snapshot.value.objectForKey("profileImage") as! String
        
    })
}

func elapsedTime(seconds: NSTimeInterval) -> String {
    var elapsed : String?
    
    if seconds < 60 {
        elapsed = "Just Now"
    } else if seconds < 60*60 {
        let minutes = Int(seconds / 60)
        var minText = "min ago"
        
        if minutes > 1 {
            minText = "mins ago"
        }
        
        elapsed = "\(minutes) \(minText)"
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        var hoursText = "hour ago"
        if hours > 1 {
            hoursText = "hours ago"
        }
        elapsed = "\(hours) \(hoursText)"
    } else {
        let days = Int(seconds / (24 * 60 * 60))
        var dayText = "day ago"
        if days > 1 {
            dayText = "days ago"
        }
        elapsed = "\(days) \(dayText)"
    }
    return elapsed!
}

func DeleteRecentItem(recent : NSDictionary){
    ref.childByAppendingPath("Recent").childByAppendingPath(recent["recentId"] as? String).removeValueWithCompletionBlock { (error, ref) in
        if error != nil {
            print("Error deleting recent item: \(error)")
        }
    }
    
}

func RestartRecentChat(recent : NSDictionary){
    for userId in recent["members"] as! [String] {
        
        if userId != NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String {
            createRecent(userId, chatRoomId: (recent["chatRoomId"] as! String), members: recent["members"] as! [String], withUserUsername: currentUser, withUseruserId: NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String, withTitle: recent["listingTitle"] as! String, withPImage: currentProfileImg)
        }
    }
    
}

func createRecent(userId : String, chatRoomId : String, members : [String], withUserUsername : String, withUseruserId : String, withTitle : String, withPImage : String){
    
    ref.childByAppendingPath("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRoomId).observeSingleEventOfType(.Value, withBlock: {
        snapshot in
        
        var createRecent = true
        
        if snapshot.exists() {
            
            for recent in snapshot.value.allValues {
                if recent["userId"] as! String == NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String {
                    print("haskhdfkashfkjashdfjksadhfkashdfkjashdkfashdfkashdfsajdhfkjasdnvaskdnvasvb")
                    createRecent = false
                }
                
            }
        }
        
        if createRecent {
            createRecentItem(userId, chatRoomId: chatRoomId, members: members, withUserUsername: withUserUsername, withUserId: withUseruserId, withTitle : withTitle, withPImage : withPImage)
        }
    })
    
}

func createRecentItem(userId : String, chatRoomId : String, members : [String], withUserUsername : String, withUserId : String, withTitle : String, withPImage : String){
    
    let recentRef = ref.childByAppendingPath("Recent").childByAutoId()
    let recentId = recentRef.key
    let date = dateFormatter().stringFromDate(NSDate())
    
    let recent = [
        "recentId" : recentId,
        "userId" : userId,
        "chatRoomId" : chatRoomId,
        "members" : members,
        "withUserUsername" : withUserUsername,
        "lastMessage" : "",
        "counter" : 0,
        "date" : date,
        "withUserUserId" : withUserId,
        "listingTitle" : withTitle,
        "usersProfileImage" : withPImage
    ]
    
    recentRef.setValue(recent) {(error, ref) -> Void in
        if error != nil {
            print("error creating recent \(error)")
        }
        
    }
    
}

func UpdateRecents(chatRoomID : String, lastMessage: String){
    ref.childByAppendingPath("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: {
        snapshot in
        
        if snapshot.exists() {
            for recent in snapshot.value.allValues{
                UpdateRecentItem(recent as! NSDictionary, lastMessage: lastMessage)
            }
        }
    })
}

func UpdateRecentItem(recent: NSDictionary, lastMessage: String) {
    let date = dateFormatter().stringFromDate(NSDate())
    
    var counter = recent["counter"] as! Int
    
    if ((recent["userId"] as? String) != currentUserUID) {
        counter = counter + 1
    }
    
    let values = ["date" : date]
    
    ref.childByAppendingPath("Recent").childByAppendingPath(recent["recentId"] as? String).updateChildValues(values as [NSObject : AnyObject])
}

func getExperationDate(eDateString : String) -> String {
    var string : String = String()
    
    let eDate = dateFormatter().dateFromString(eDateString)
    
    let days = eDate!.daysFrom(NSDate())
    let hours = eDate!.hoursFrom(NSDate())
    let minutes = eDate!.minutesFrom(NSDate())
    let eseconds = eDate!.secondsFrom(NSDate())
    
    if (days > 1) {
        string = "Ends in \(days) days"
    }
    if (days == 1){
        string = "Ends in \(days) day"
    }
    if (days < 1) {
        string = "Ends in \(hours) hours"
    }
    if (hours == 1 && days == 0){
        string = "Ends in \(hours) hour"
        
    }
    if (hours == 0 && minutes != 0 && days == 0){
        string = "Ends in \(minutes) minutes"
    }
    if (minutes == 1 && hours == 0 && days == 0){
        string = "Ends in 1 minute"
    }
    if (minutes < 1 && hours == 0 && days == 0){
        string = "Ends in <1 minute"
    }
    if (eseconds < 0){
        string = "Ended. Please Renew"
        
    }
    
    
    return string
    
}



extension NSDate {
    func daysFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date: NSDate) -> String {
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}





