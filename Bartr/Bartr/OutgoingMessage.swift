//
//  OutgoingMessage.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/28/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import Foundation
import UIKit
import Firebase




class OutgoingMessage{
//Reference for messages
    private let ref = FIRDatabase.database().reference().child("messages")
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Message dictionary to hold either text messages or images
    let messageDictionary: NSMutableDictionary
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Sent a text message
    init (message: String, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [
            message, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "senderId", "senderName", "date", "status", "type"])
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Send a picture message
    init (message: String, pictureData: NSData, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        let pic = pictureData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        messageDictionary = NSMutableDictionary(objects: [
            message, pic , senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "picture", "senderId", "senderName", "date", "status", "type"])
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Send message with chatroom id and update recents to new text and time
    func sendMessage(chatRoomID : String, item: NSMutableDictionary){
        let reference = ref.child(chatRoomID).childByAutoId()
        item["messageId"] = reference.key
        reference.setValue(item) {(error, ref) -> Void in
            if error != nil {
                print("Coudnt send message")
            }
        }
        UpdateRecents(chatRoomID, lastMessage: (item["message"] as? String)!)
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
}