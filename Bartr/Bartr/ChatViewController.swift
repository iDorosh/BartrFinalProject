//
//  MessageThread.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/17/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase


class ChatViewController: JSQMessagesViewController {
    var ref : Firebase!
   
    let ref2 = Firebase(url: "\(BASE_URL)/messages")
    
    var messageDictionary: NSMutableDictionary = [:]
    
    var initialLoadComplete : Bool = false
    
    var avatar : String = String()
    var avatarImage : UIImage?
    
    var currentAvatar : String = String()
    var currentAvatarImage : UIImage?
    
    var usersTypingQuery: FQuery!
    
    var croppingEnabled: Bool = true
    var libraryEnabled: Bool = true
    var capturedImage : UIImage = UIImage()
    var recieverUsername : String = ""
    
    var recieverUID : String = ""
    var senderUID : String = ""
    var selectedTitle : String = ""
    var selectedImage : String = ""
    var selectedUser : String = ""
    var currentUser : String = ""
    
    
    let rootRef = Firebase(url: BASE_URL)


    var objects : [NSDictionary] = []
    var loaded : [NSDictionary] = []
    
    var recent : NSDictionary?
    var chatRoomID : String = ""
    
    var previous : String = ""
    
    
    
    
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .Default
        title = recieverUsername
        setupBubbles()
        

        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30,30)
        
        if previous != "TBLV"{
            chatRoomID = startChat(senderUID, user2: recieverUID)
        }
        

        
        observeMessages()
      
    }
    
    func openCamera()
    {
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            self!.capturedImage = image!
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    func openLibrary(){
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            self.capturedImage = image!
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(libraryViewController, animated: true, completion: nil)
    }

    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            hexStringToUIColor("#f27163"))
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            hexStringToUIColor("#2b3146"))
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "Image2"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault));
        } else { //
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "Image1"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault));
        }
        
    }
    
    


    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "User", text: text)
        messages.append(message)
    }
    
        
    override func didPressAccessoryButton(sender: UIButton!) {
        openCamera()
    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
               senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = ref2.childByAppendingPath(chatRoomID).childByAutoId() // 1
        let messageItem = [ // 2
            "text": text,
            "senderId": senderId,
        ]
        itemRef.setValue(messageItem) // 3
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
        
    
        
    }
    
    func observeMessages() {
        ref2.childByAppendingPath(chatRoomID).observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            // 3
            if snapshot.exists() {
                let id = snapshot.value["senderId"] as! String
                let text = snapshot.value["text"] as! String
                
                // 4
                self.addMessage(id, text: text)
                
                // 5
                self.finishReceivingMessage()
                
                UpdateRecents(self.chatRoomID, lastMessage: text)
            }
        }
    }

    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        //isTyping = textView.text != ""
    }
    
    
    var userIsTypingRef: Firebase! // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.childByAppendingPath("typingIndicator")
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        // 1
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        // 2
        usersTypingQuery.observeEventType(.Value) { (data: FDataSnapshot!) in
            
            // 3 You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 4 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }

    }
    
        
    func startChat (user1 : String, user2: String) -> String {
        let userId1 = user1
        let userId2 = user2
        
        var chatRoomId : String = ""
        let value = userId1.compare(userId2).rawValue
        
        if value < 0 {
            chatRoomId = userId1.stringByAppendingString(userId1)
        }else {
            chatRoomId = userId2.stringByAppendingString(userId2)
        }
        
        let members = [userId1, userId2]
        createRecent(userId1, chatRoomId: chatRoomId, members: members, withUserUsername: selectedUser, withUseruserId: userId2, withTitle : selectedTitle, withPImage : selectedImage)
        
        createRecent(userId2, chatRoomId: chatRoomId, members: members, withUserUsername: currentUser, withUseruserId: userId1, withTitle : selectedTitle, withPImage : currentProfileImg)
        
        
        return chatRoomId
    }
    
    


}
