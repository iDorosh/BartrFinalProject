//
//  MainFeed.swift
//  BartrFirstViewController
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView



class MainFeed: UIViewController, UITableViewDataSource {
    @IBAction func backToMain(segue: UIStoryboardSegue){}
    
    
//Variables
    //Data
    var posts = [Post]()
    var hideCompleteSales = [Post]()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //String
    var currentUser : String = ""
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Integers
    var selectedPost: Int = Int()
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Refresh controller
    var refreshControl: UIRefreshControl!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//Outlets
    @IBOutlet weak var spin: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
//UI
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        updatePosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spin.startAnimating()
        spin.hidden = false
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        
        setUserDefaults()
        setUpRefreshControl()
        
        if !signUpSkipped{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.tabBarController = self.tabBarController!
            appDelegate.observeOffers()
            appDelegate.getCurrentUserData()
            appDelegate.getRecentsObserver()
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

//Functions
    //Tableview Setup
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if hideCompleteSales.count > 0 {
                tableView.hidden = false
            } else {
                tableView.hidden  = true
            }
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
    
        //Adds pull to refresh to the main table view
        func setUpRefreshControl(){
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(MainFeed.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
            tableView.addSubview(refreshControl)
        }
    
    
    //Check if user is signed in
        func setUserDefaults(){
            if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && FIRAuth.auth()?.currentUser?.uid != nil {
                signUpSkipped = false
            } else {
                signUpSkipped = true
            }
        }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
    //Firebase
        //Update Firebase Data and update Table View
            func refresh(sender:AnyObject) {
                updatePosts()
            }
        
        
        //Update Firebase and Table View
            func updatePosts(){
                DataService.dataService.POST_REF.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    self.posts = []
                    self.hideCompleteSales = []
                    
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        //Get all posts
                        for snap in snapshots {
                            if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = Post(key: key, dictionary: postDictionary)
                                self.posts.insert(post, atIndex: 0)
                            }
                        }
                    }

                        //Filter out completed or expired posts
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
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//

    //Pass Data
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailSegue"){
            let details : PostDetails = segue.destinationViewController as! PostDetails
            details.key = hideCompleteSales[selectedPost].postKey
            details.previousVC = "MainFeed"
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------------//
    
}


