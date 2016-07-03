//
//  MainFeed.swift
//  BartrFirstViewController
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase



class MainFeed: UIViewController, UITableViewDataSource {
    @IBAction func backToMain(segue: UIStoryboardSegue){}
    
    //Variables
    var currentUser : String = ""
    
    //All posts class
    var posts = [Post]()
    var hideCompleteSales = [Post]()
    
    //Selected post index
    var selectedPost: Int = Int()
    
    //Refresh control to manually update the Main Feed TableView
    var refreshControl: UIRefreshControl!
    
    
    
    
    @IBOutlet weak var spin: UIActivityIndicatorView!
   
    
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var LogInLogOut: UIButton!
    
    //Actions
    @IBAction func logOutUser(sender: UIButton) {
        logOutUser()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spin.startAnimating()
        spin.hidden = false
        
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        updatePosts()
        setUserDefaults()
        setUpRefreshControl()
       
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Tableview Setup
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hideCompleteSales.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let post = hideCompleteSales[indexPath.row]
        
        let cell : CustomTableCell = tableView.dequeueReusableCellWithIdentifier("MyCell")! as! CustomTableCell
        
        cell.configureCell(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        selectedPost = indexPath.row
        performSegueWithIdentifier("detailSegue", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    //Functions
    
    //Update Firebase Data and update Table View
    func refresh(sender:AnyObject) {
        updatePosts()
    }
    
    //Check if user is signed in
    func setUserDefaults(){
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && DataService.dataService.CURRENT_USER_REF.authData != nil {
            LogInLogOut.setTitle("Sign Out", forState: UIControlState.Normal)
        } else {
            LogInLogOut.setTitle("Sign In", forState: UIControlState.Normal)
        }
    }
    
    //Adds pull to refresh to the main table view
    func setUpRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainFeed.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
         
    }
    
    //Sign user out when the alert view confirm button is clicked
    func signOutCallBack() {
        DataService.dataService.CURRENT_USER_REF.unauth()
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
    
    //Logout User alert view shows
    func logOutUser(){
        if (LogInLogOut.currentTitle == "Sign Out"){
            
            let alertview = JSSAlertView().show(
                self,
                title: "Sign Out Current User?",
                buttonText: "Sign Out",
                cancelButtonText: "Cancel" // This tells JSSAlertView to create a two-button alert
            )
            alertview.addAction(signOutCallBack)
            
        } else {
            let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
            UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
        }
        
    }
    
    //Update Firebase and Table View
    func updatePosts(){
        DataService.dataService.POST_REF.observeEventType(.Value, withBlock: { snapshot in
            self.posts = []
            self.hideCompleteSales = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(key: key, dictionary: postDictionary)
                        self.posts.insert(post, atIndex: 0)
                    }
                }
            }


            
                for i in self.posts
                {
                    
                    let eDateString : String = i.expireDate
                    let eDate = dateFormatter().dateFromString(eDateString)
                    
                    let eseconds = eDate!.secondsFrom(NSDate())
                    
                    if !i.postComplete && !i.postFL && eseconds > 0{
                        self.hideCompleteSales.append(i)
                    }
                }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.spin.hidden = true
            self.spin.stopAnimating()
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "detailSegue"){
            let details : PostDetails = segue.destinationViewController as! PostDetails
            details.currentUser = currentUser
            details.key = posts[selectedPost].postKey
            details.previousVC = "MainFeed"
        }
    }
}


