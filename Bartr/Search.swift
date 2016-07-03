//
//  Search.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class Search: UIViewController, CLLocationManagerDelegate, UITableViewDataSource {
    @IBAction func backToSearch(segue: UIStoryboardSegue){}
    
    //Data
    var posts = [Post]()
    var filteredPosts = [Post]()
    var selectedPost: Int = Int()
    
    //Variables
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    var initialLocation = CLLocation()
    var foundLocation : Bool = false
    var filterType : String = String()

    //Outlets
    @IBOutlet weak var tabletView: UITableView!
    
    @IBOutlet weak var viewType: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var searchBar: UITextField!
    
    @IBOutlet weak var spin: UIActivityIndicatorView!
    
    
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
    
    @IBAction func listingDistance(sender: UISegmentedControl) {
    }
    
    
    //FilterView
    @IBOutlet weak var filterView: UIView!
    
    //Actions
    @IBAction func changeViewType(sender: UIButton) {
        changeViewType()
    }
    
    @IBAction func showFilter(sender: UIButton) {
        blurView.hidden = false
        filterView.hidden = false
    }
    
    @IBAction func hideFilter(sender: UIButton) {
        blurView.hidden = true
        filterView.hidden = true
    }
    
    @IBAction func applyFilter(sender: UIButton) {
        updatePosts(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spin.startAnimating()
        spin.hidden = false
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //Update firebase data and Table View
        updatePosts(false)
        //Setup Map View
        setUpMapView()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.blurView.addSubview(blurEffectView)
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let post = filteredPosts[indexPath.row]
        let cell : CustomTableCell = tableView.dequeueReusableCellWithIdentifier("MyCell")! as! CustomTableCell
        cell.configureCell(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        selectedPost = indexPath.row
        performSegueWithIdentifier("detailSegue", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //Update Firebase data and Table View
    func updatePosts(filtered : Bool){
        DataService.dataService.POST_REF.observeEventType(.Value, withBlock: { snapshot in
            self.posts = []
            self.filteredPosts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(key: key, dictionary: postDictionary)
                        self.posts.insert(post, atIndex: 0)
                    }
                }
            }
            
            //Get current users posts
            if !filtered{
                for i in self.posts
                {
                    let eDateString : String = i.expireDate
                    let eDate = dateFormatter().dateFromString(eDateString)
                    
                    let eseconds = eDate!.secondsFrom(NSDate())
                    
                    if !i.postComplete && !i.postFL && eseconds > 0{
                        self.filteredPosts = self.posts
                    }
                }
                
                
            } else {
                for i in self.posts
                {
                    if (i.postType.containsString(self.filterType) && !i.postComplete && !i.postFL){
                        self.filteredPosts.append(i)
                    }
                }
            }
            

            self.spin.stopAnimating()
            self.spin.hidden = true
            self.tabletView.reloadData()
            self.blurView.hidden = true
            self.filterView.hidden = true
        })
    }
    
    //Zoom map to current position
    func setUpMapView(){
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //Center current postition in map view
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        initialLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        if !foundLocation {
            centerMapOnLocation(initialLocation)
            foundLocation = true
        }
    }
    
    //Change between table view and map view
    func changeViewType(){
        if (viewType.currentTitle == "Map"){
            mapView.hidden = false
            tabletView.hidden = true
            viewType.setTitle("List", forState: .Normal)
            
            for listings in filteredPosts{
                let location: String = listings.postLocation
                let geocoder: CLGeocoder = CLGeocoder()
                geocoder.geocodeAddressString(location,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                    if (placemarks?.count > 0) {
                        let topResult: CLPlacemark = (placemarks?[0])!
                        let placemark: MKPlacemark = MKPlacemark(placemark: topResult)
                        var region: MKCoordinateRegion = self.mapView.region
                        region.center = placemark.coordinate
                        region.span.longitudeDelta /= 50.0
                        region.span.latitudeDelta /= 50.0
                        
                        
                        self.mapView.setRegion(region, animated: true)
                        self.mapView.addAnnotation(placemark)
                    }
                })

            }  
            
        } else {
            mapView.hidden = true
            tabletView.hidden = false
            viewType.setTitle("Map", forState: .Normal)
        }
    }
    

    //Send data to next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailSegue"){
            let details : PostDetails = segue.destinationViewController as! PostDetails
            details.key = posts[selectedPost].postKey
            details.previousVC = "Search"
        }
    }
}
