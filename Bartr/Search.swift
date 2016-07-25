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




class Search: UIViewController, UITableViewDataSource, UITextFieldDelegate, CustomIOS8AlertViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBAction func backToSearch(segue: UIStoryboardSegue){}
    
    //Data
    var posts = [Post]()
    var allPosts = [Post]()
    var filteredPosts = [Post]()
    var searchingResults = [Post]()
    var customFilterView : CustomIOS8AlertView! = nil
    var selectedAnnotationTitle : String = String()
    var searchActive : Bool = false
    var filtered : Bool = false
    
    @IBOutlet weak var mapSearchArealLavel: UIButton!
    @IBOutlet weak var mapFilterBttn: UIButton!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var changeViewlabel: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func changeView(sender: UIButton) {
        self.view.endEditing(true)
        if mapView.hidden {
            mapView.hidden = false
            filterView.hidden = false
            changeViewlabel.setTitle("List", forState: .Normal)
        } else {
            mapView.hidden = true
            filterView.hidden = true
            changeViewlabel.setTitle("Map", forState: .Normal)
        }
    }
    
    @IBOutlet weak var filterBttn: UIButton!
    
    @IBOutlet weak var searchAreaLabel: UIButton!
    //Variables
    var post : Post!
    var foundLocation : Bool = false
    var filterType : String = String()
    var selectedPost: Int = Int()
    var action : Int = 0
    var searching = false
    var reloadPosts = false
    var distanceMiles : Int = 500
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
        self.view.endEditing(true)
        ShowFilters()
    }
    
    
    @IBAction func applyFilter(sender: UIButton) {
        filtered = false
        resetFilter()
    }
    
    func resetFilter(){
        forSale.checkState = .Unchecked
        trade.checkState = .Unchecked
        free.checkState = .Unchecked
        looking.checkState = .Unchecked
        
        setLocationManager()
        
        distance.selectedSegmentIndex = 3
        distanceMiles = 200
        searchActive = true
        reloadPosts = false
        if searchActive {
            searchFirebase()
        }
        getCheckStates()
        setCheckStates()
        

    }
    
    @IBAction func cancelClicked(sender: UIButton) {
        filterBttn.hidden = true
        searchAreaLabel.setTitle("In Your Area", forState: .Normal)
        mapFilterBttn.hidden = true
        mapSearchArealLavel.setTitle("In Your Area", forState: .Normal)
        cancelSearch.userInteractionEnabled = false
        cancelSearch.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        searchBar.text = ""
        resetFilter()
        searchActive = false
        filtered = false
        action = 0
        self.view.endEditing(true)
        searchingResults = []
        filteredPosts = []
        updatePosts()
       
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
        filterBttn.hidden = true
        mapFilterBttn.hidden = true
        loadUI()
        getCheckStates()
        setLocationManager()
        setUpRefreshControl()
        mapView.delegate = self
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
    
        

        searchActive = true
        action = 1
        tabletView.reloadData()
        cancelSearch.userInteractionEnabled = true
        cancelSearch.setTitleColor(hexStringToUIColor("#2b3146"), forState: .Normal)
        if textField.text == "" {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    func searchDidChange(textView: UITextView) {
        if mapView.hidden == true {
            searchFirebase()
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        filterBttn.hidden = false
        searchAreaLabel.setTitle("Search Results", forState: .Normal)
        mapSearchArealLavel.setTitle("Search Results", forState: .Normal)
        mapFilterBttn.hidden = false
        dismissKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if mapView.hidden == false {
            searchFirebase()
        }
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch action {
        case 0:
            if posts.count > 0 {
                tabletView.hidden = false
            } else {
                tabletView.hidden  = true
            }
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
        if !searchActive {
            DataService.dataService.POST_REF.observeSingleEventOfType(.Value, withBlock: { snapshot in
                self.posts = []
                self.allPosts = []
            
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        if !(snap.value!.objectForKey("postComplete") as! Bool) && !(snap.value!.objectForKey("postFeedbackLeft") as! Bool) {
                            if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let post = Post(key: key, dictionary: postDictionary)
                                
                                self.allPosts.insert(post, atIndex: self.allPosts.endIndex
                                )
                            }
                        }
                    }
                }
                
                for i in self.allPosts {
                    if self.loadLocation(i.lon, lat : i.lat){
                        self.posts.insert(i, atIndex: 0)
                    }
                }
                
                self.action = 0
                self.refreshControl.endRefreshing()
                self.spin.stopAnimating()
                self.spin.hidden = true
                self.tabletView.reloadData()
                self.setMapLocation()
            })
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func setMapLocation(){
        mapView.removeAnnotations(mapView.annotations)
        if searchActive {
            if filtered {
                for i in filteredPosts {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: (Double(i.lat)! + Double.random(0.001, 0.01)), longitude: (Double(i.lon)!) + Double.random(0.001, 0.01))
                    annotation.title = i.postTitle
                    mapView.addAnnotation(annotation)
                }
            } else {
                for i in searchingResults {
                
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: (Double(i.lat)! + Double.random(0.001, 0.01)), longitude: (Double(i.lon)!) + Double.random(0.001, 0.01))
                    annotation.title = i.postTitle
                    mapView.addAnnotation(annotation)
                }
            }
        } else {
            for i in posts {
                let annotation = MKPointAnnotation()
                Double.random(0.000456, 0.001000)
                annotation.coordinate = CLLocationCoordinate2D(latitude: (Double(i.lat)! + Double.random(0.001, 0.01)), longitude: (Double(i.lon)!) + Double.random(0.001, 0.01))
                annotation.title = i.postTitle
                
                mapView.addAnnotation(annotation)
            }
        }
        
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
                            if self.loadLocation(post.lon, lat: post.lat) {
                                self.searchingResults.insert(post, atIndex: 0)
                            }
                        }
                    }
                }
                
            }
            
                    self.action = 1
                    self.tabletView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.setMapLocation()
        })
        
    }
    
    
    
    //Get listing location on map preview
    func loadLocation(lon: String, lat : String) -> Bool{
        let checkLocation = CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
        
        if two != nil {
            if two.distanceFromLocation(checkLocation)/1609 < Double(distanceMiles) {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    
    }
    
    func mapView(_mapView: MKMapView,
                 viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            
            pinView!.rightCalloutAccessoryView = UIButton(type: .InfoLight) as UIButton
        }
        else {
            pinView!.annotation = annotation
            
        }
        return pinView
    }
    
    func mapView(MapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            selectedAnnotationTitle = ((annotationView.annotation?.title)!)!
            performSegueWithIdentifier("detailSegue", sender: self)
        }
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
        

        
        let center = CLLocationCoordinate2D(latitude: two.coordinate.latitude, longitude: two.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.30, longitudeDelta: 0.30))
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }


    
    
    //Send data to next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailSegue"){
            let details : PostDetails = segue.destinationViewController as! PostDetails

            if (mapView.hidden){
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
            } else {
                for i in posts {
                    if i.postTitle == selectedAnnotationTitle {
                        details.key = i.postKey
                    }
                }
            }
            details.previousVC = "Search"
        }
    }
    
    func ShowFilters(){
        filters.hidden = false
        customFilterView = CustomIOS8AlertView()
        customFilterView.delegate = self
        customFilterView.containerView = filters
        customFilterView.buttonColor = hexStringToUIColor("#2b3146")
        customFilterView.buttonColorHighlighted = hexStringToUIColor("#a6a6a6")
        customFilterView.buttonTitles = ["Done"]
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
        filters.hidden = true
        customFilterView.close()
    }
    
    func checkForFilters(){
        type.removeAll()
        reloadPosts = false
        
        if forSale.checkState == .Checked {
            type.append("Sale")
            print("sale")
            reloadPosts = true
        }
        if trade.checkState == .Checked {
            type.append("Trade")
            reloadPosts = true
            print("trade")
        }
        if looking.checkState == .Checked {
            type.append("Looking")
            reloadPosts = true
            print("looking")
        }
        if free.checkState == .Checked {
            type.append("Free")
            reloadPosts = true
            print("printfree")
        }
        
        if distance.selectedSegmentIndex != 3 && !reloadPosts{
            loadDistanceResults()
            
        } else {
            if reloadPosts  {
                filterPosts()
                action = 1
            } else {
                type = []
                action = 1
                filtered = false
                setMapLocation()
                tabletView.reloadData()
            }
        }
        
        
        

        getCheckStates()
    }
    
    func loadDistanceResults(){
        filteredPosts = []
        filtered = true
        distanceMiles = Int(distance.titleForSegmentAtIndex(distance.selectedSegmentIndex)!)!
        for i in searchingResults {
            if loadLocation(i.lon, lat: i.lat){
                filteredPosts.append(i)
                print("loading")
            }
                        
        }
        
        setMapLocation()
        action = 2
        tabletView.reloadData()
        
    }

    
    
   
    func filterPosts(){
        filteredPosts = []
        filtered = true
        mapView.removeAnnotations(mapView.annotations)
        if distance.selectedSegmentIndex == 1 {
            for i in searchingResults {
                if !type.isEmpty {
                    for types in type {
                        if i.postType.containsString(types) {
                           filteredPosts.append(i)
                        }
                    }
                }
            }
        } else {
            distanceMiles = Int(distance.titleForSegmentAtIndex(distance.selectedSegmentIndex)!)!
            for i in searchingResults {
                if !type.isEmpty {
                    for types in type {
                        if i.postType.containsString(types) {
                            if loadLocation(i.lon, lat: i.lat){
                                filteredPosts.append(i)
                            }
                            
                        }
                    }
                }
            }

        }
        
        
            setMapLocation()
            action = 2
            tabletView.reloadData()
    }
    
    
    
}



public extension Double {
    /// SwiftRandom extension
    public static func random(lower: Double = 0, _ upper: Double = 100) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}




extension MKMapView {
    func fitMapViewToAnnotaionList() -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 100, left: 60, bottom: 100, right: 60)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<self.annotations.count {
            let annotation = self.annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        self.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
}
