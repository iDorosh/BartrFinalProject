//
//  Search.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import M13Checkbox
import MapKit




class Search: UIViewController, UITableViewDataSource, UITextFieldDelegate, CustomIOS8AlertViewDelegate, CLLocationManagerDelegate {
    @IBAction func backToSearch(segue: UIStoryboardSegue){}
    
    //Data
    var posts = [Post]()
    var filteredPosts = [Post]()
    var searchingResults = [Post]()
    var customFilterView : CustomIOS8AlertView! = nil
    
    //Variables
    var post : Post!
    var foundLocation : Bool = false
    var filterType : String = String()
    var selectedPost: Int = Int()
    var action : Int = 0
    var searching = false
    var reloadPosts = false
    var distanceMiles : Int = 20
    var locationFound : Bool = false
    var locationManager = CLLocationManager()
    var two : CLLocation!
    var refreshControl: UIRefreshControl!
    
    var forSaleState : M13Checkbox.CheckState?
    var lookingState : M13Checkbox.CheckState?
    var freeState : M13Checkbox.CheckState?
    var tradeState : M13Checkbox.CheckState?
    
    var type : [String] = []
    
    //Outlets
    @IBOutlet weak var tabletView: UITableView!
    @IBOutlet var cancelSearch: UIButton!
    @IBOutlet weak var viewType: UIButton!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var spin: UIActivityIndicatorView!
    @IBOutlet weak var distance: UISegmentedControl!
    
    
    @IBOutlet weak var forSale: M13Checkbox!
    @IBOutlet weak var looking: M13Checkbox!
    @IBOutlet weak var trade: M13Checkbox!
    @IBOutlet weak var free: M13Checkbox!
    
  
    @IBOutlet var filters: UIView!

    //Actions
    @IBAction func listingDistance(sender: UISegmentedControl) {}
    
    @IBAction func showFilter(sender: UIButton) {
        ShowFilters()
    }
    
    @IBAction func hideFilter(sender: UIButton) {
        setCheckStates()
        customFilterView.close()
    }
    
    @IBAction func applyFilter(sender: UIButton) {
        forSale.checkState = .Unchecked
        trade.checkState = .Unchecked
        free.checkState = .Unchecked
        looking.checkState = .Unchecked
        
        
        distance.selectedSegmentIndex = 1
        reloadPosts = false
        updatePosts()
        getCheckStates()
        setCheckStates()
    }
    
    @IBAction func cancelClicked(sender: UIButton) {
        cancelSearch.userInteractionEnabled = false
        cancelSearch.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        action = 0
        tabletView.reloadData()
        searchBar.text = ""
    }
    
    @IBAction func listingType(sender: UISegmentedControl) {
        let selectedIndex : Int = sender.selectedSegmentIndex
        
        switch selectedIndex {
        case 0:
            filterType = "Sale"
        case 1:
            filterType = "Trade"
        case 2:
            filterType = "Looking"
        case 3:
            filterType = "Free"
        default:
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
        getCheckStates()
        setLocationManager()
        setUpRefreshControl()
    }

    override func viewDidAppear(animated: Bool) {
        updatePosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadUI(){
        spin.startAnimating()
        spin.hidden = false
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Update firebase data and Table View
        updatePosts()
        searchBar.delegate = self
        cancelSearch.userInteractionEnabled = false
        cancelSearch.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        
        searchBar.addTarget(self, action: #selector(self.searchDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func setUpRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(Search.updatePosts), forControlEvents: UIControlEvents.ValueChanged)
        tabletView.addSubview(refreshControl)
        
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        cancelSearch.userInteractionEnabled = true
        cancelSearch.setTitleColor(hexStringToUIColor("#2b3146"), forState: .Normal)
    }
    
    func searchDidChange(textView: UITextView) {
        searchFirebase()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let trimmedString = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if trimmedString.characters.count == 0 {
            cancelSearch.userInteractionEnabled = false
            cancelSearch.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch action {
        case 0:
            return posts.count
        case 1:
            return searchingResults.count
        case 2:
            return filteredPosts.count
        default:
            return posts.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        switch action {
        case 0:
            post = posts[indexPath.row]
        case 1:
            post = searchingResults[indexPath.row]
        case 2:
            post = filteredPosts[indexPath.row]
        default:
            break
        }
    
        let cell : CustomTableCell = tableView.dequeueReusableCellWithIdentifier("MyCell")! as! CustomTableCell
        cell.configureCell(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        selectedPost = indexPath.row
        dismissKeyboard()
        performSegueWithIdentifier("detailSegue", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //Update Firebase data and Table View
    func updatePosts(){
        DataService.dataService.POST_REF.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if !(snap.value!.objectForKey("postComplete") as! Bool) && !(snap.value!.objectForKey("postFeedbackLeft") as! Bool) {
                        if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                            if !self.reloadPosts {
                                let key = snap.key
                                let post = Post(key: key, dictionary: postDictionary)
                                self.posts.insert(post, atIndex: 0)
                            } else {
                                if !self.type.isEmpty {
                                    var add = true
                                    var exists = false
                                    for i in self.type {
                                        if !(snap.value!.objectForKey("postType") as! String).containsString(i) {
                                            add = false
                                        }
                                        if add {
                                            let key = snap.key
                                            let post = Post(key: key, dictionary: postDictionary)
                                            for i in self.posts {
                                                if i.postKey == key {
                                                    exists = true
                                                }
                                            }
                                            if !exists && self.loadLocation(post.postLocation){
                                                self.posts.insert(post, atIndex: 0)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        
                        }
                    }
                }
            }
            self.refreshControl.endRefreshing()
            self.reloadPosts = false
            self.spin.stopAnimating()
            self.spin.hidden = true
            self.tabletView.reloadData()
        })
    }
    
    func searchFirebase(){
        searchingResults = []
        DataService.dataService.POST_REF.queryOrderedByChild("postTitle").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    let postTitle: String = (snap.value?.objectForKey("postTitle"))! as! String
                    let searchText: String = self.searchBar.text!
                    
                    if postTitle.lowercaseString.containsString(searchText.lowercaseString) && !(snap.value!.objectForKey("postComplete") as! Bool) && !(snap.value!.objectForKey("postFeedbackLeft") as! Bool){
                        if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let post = Post(key: key, dictionary: postDictionary)
                            self.searchingResults.insert(post, atIndex: 0)
                        }
                    }
                }
                
            }
                if self.searchingResults.count == 0{
                    self.action = 0
                    self.tabletView.reloadData()
                } else {
                    self.action = 1
                    self.tabletView.reloadData()
                }
                self.refreshControl.endRefreshing()
        })
        
    }
    
    
    
    //Get listing location on map preview
    func loadLocation(location : String) -> Bool{
        let geocoder: CLGeocoder = CLGeocoder()
        var distanceTest : Int = Int()
        
        geocoder.geocodeAddressString(location,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count > 0) {
                let topResult: CLPlacemark = (placemarks?[0])!
                
                let one =  topResult.location
                distanceTest = (Int((one?.distanceFromLocation(self.two))!)/1609)
                print("\(location) \(distanceTest)")
            }
            if distanceTest > self.distanceMiles {
                print("false")
            } else {
                print("\(self.distanceMiles) \(distanceTest)")
                print("true")
            }

        })
        return true
    }
    
    func setLocationManager(){
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        two = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        locationManager.stopUpdatingHeading()
    }


    
    
    //Send data to next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailSegue"){
            let details : PostDetails = segue.destinationViewController as! PostDetails
            switch action {
            case 0:
                details.key = posts[selectedPost].postKey
            case 1:
                details.key = searchingResults[selectedPost].postKey
            case 2:
                details.key = filteredPosts[selectedPost].postKey
            default:
                details.key = posts[selectedPost].postKey
            }
            details.previousVC = "Search"
        }
    }
    
    func ShowFilters(){
        customFilterView = CustomIOS8AlertView()
        customFilterView.delegate = self
        customFilterView.containerView = filters
        customFilterView.buttonColor = hexStringToUIColor("#2b3146")
        customFilterView.buttonColorHighlighted = hexStringToUIColor("#a6a6a6")
        customFilterView.buttonTitles = ["Apply Filter"]
        customFilterView.tintColor = hexStringToUIColor("#f27163")
        customFilterView.show()
    }
    
    func getCheckStates(){
        forSaleState = forSale.checkState
        tradeState = trade.checkState
        lookingState = looking.checkState
        freeState = free.checkState
    }
    
    func setCheckStates(){
        forSale.checkState = forSaleState!
        trade.checkState = tradeState!
        looking.checkState = lookingState!
        free.checkState = freeState!
    }
    
    func customIOS8AlertViewButtonTouchUpInside(alertView: CustomIOS8AlertView, buttonIndex: Int) {
        checkForFilters()
        customFilterView.close()
    }
    
    func checkForFilters(){
        type.removeAll()
        reloadPosts = false
        
        if forSale.checkState == .Checked {
            type.append("Sale")
            reloadPosts = true
        }
        if trade.checkState == .Checked {
            type.append("Trade")
            reloadPosts = true
        }
        if looking.checkState == .Checked {
            type.append("Looking")
            reloadPosts = true
        }
        if free.checkState == .Checked {
            type.append("Free")
            reloadPosts = true
        }
        
        if distance.selectedSegmentIndex != 20 {
            distanceMiles = Int(distance.titleForSegmentAtIndex(distance.selectedSegmentIndex)!)!
        } else {
            distanceMiles = 20
        }
        
        getCheckStates()
        
        if reloadPosts {
            updatePosts()
        }
    }
}
