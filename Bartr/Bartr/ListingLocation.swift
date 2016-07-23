//
//  ListingLocation.swift
//  Bartr
//
//  Created by Ian Dorosh on 7/6/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import SCLAlertView
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ListingLocation: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UISearchControllerDelegate {
    @IBAction func backToLocation(segue: UIStoryboardSegue){}
    
    let locationManager = CLLocationManager()
    var selectedLocation : CLLocationCoordinate2D!
    var city : String = String()
    var longitude : Double = Double()
    var latitude : Double = Double()
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    var lat : Double = Double()
    var lon : Double = Double()

    @IBOutlet weak var scrollView: UIScrollView!
    
    var pickedImage: UIImage = UIImage()
    var pickedTitle : String = String()
    var pickedLocation : String = String()
    var type : [String] = []
    var typesString : String = String()
    var pickedPrice : String = String()
    
    var previousScreen : String = String()
    var editTitle : String = String()
    var editPrice : String = String()
    var editLocation : String = String()
    var editPhoto : UIImage = UIImage()
    var editType : String = String()
    var editProfileImg : String = String()
    var editUser : String = String()
    var editDetails : String = String()
    var editKey : String = String()
    
    
    @IBAction func detailViewNext(sender: UIButton) {

        performSegueWithIdentifier("NextInfoSegue", sender: self)
    }

    
    
    
    var locationFound : Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false

        loadLocation()
     
        if previousScreen != "EditView"{
            setLocationManager()
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Set up loaction manager to get the current posistion
    func setLocationManager(){
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func loadLocation(){
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }
    
    var zoom : Bool = false
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        lat = locValue.latitude
        lon = locValue.longitude
        if (!zoom){
            zoom = true
            movePosition()
        }
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
    
    func movePosition(){
        let latitude:CLLocationDegrees = lat
        
        let longitude:CLLocationDegrees = lon
        
        let latDelta:CLLocationDegrees = 0.05
        
        let lonDelta:CLLocationDegrees = 0.05
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.showsUserLocation = true
        
        mapView.setRegion(region, animated: false)
    }

    

    @IBAction func discard(sender: UIBarButtonItem) {
        discardNew("Discard Listing", subTitle: "Listing will be discarded")
    }
    

    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIApplication.sharedApplication().statusBarHidden = false
        
        if (segue.identifier == "NextInfoSegue"){
            if(previousScreen == "EditView"){
                let details : Details = segue.destinationViewController as! Details
                details.editType = editType
                details.previousScreen = "EditView"
                details.pickedImage = pickedImage
                details.pickedTitle = pickedTitle
                details.pickedLocation = city
                details.editProfileImg = editProfileImg
                details.editPhoto = editPhoto
                details.editUser = editUser
                details.editDetails = editDetails
                details.editKey = editKey
                details.pickedPrice = pickedPrice
            } else {
                let details : Details = segue.destinationViewController as! Details
                details.pickedImage = pickedImage
                details.pickedTitle = pickedTitle
                details.pickedPrice = pickedPrice
                details.pickedLocation = city
                details.longitude = longitude
                details.latitude = latitude
                }
            }
    }
    
    func removeListing(){
        if previousScreen == "EditView"{
            performSegueWithIdentifier("MainSegue", sender: self)
        } else {
            performSegueWithIdentifier("MainSegue", sender: self)
        }
        
    }

    
    func discardNew(title : String, subTitle : String){
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.addButton("Discard") {
            self.removeListing()
        }
        alertView.addButton("Don't Discard") {
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.showWarning(title, subTitle: subTitle)
    }
    
    

}


extension ListingLocation: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
            self.city = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        longitude = placemark.coordinate.longitude
        latitude = placemark.coordinate.latitude
        
    }
}

extension ListingLocation : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        button.addTarget(self, action: #selector(ListingLocation.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}


