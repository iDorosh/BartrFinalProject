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

class ListingLocation: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    

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
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var cityField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        cityField.delegate = self
        if previousScreen != "EditView"{
            setLocationManager()
        } else {
            cityField.text = pickedLocation
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
    
    
    //Sets proper view postition when keyboard pops up
    func textFieldDidBeginEditing(textField: UITextField) {
        UIApplication.sharedApplication().statusBarHidden = true
        if (textField == cityField){
            scrollView.setContentOffset(CGPointMake(0,135), animated: true)
        }
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === cityField) {
            self.view.endEditing(true)
            loadLocation()
            scrollView.setContentOffset(CGPointMake(0,0), animated: true)
        }
        return true
    }
    
    
    @IBAction func discard(sender: UIButton) {
        discardNew("Discard Listing", subTitle: "Listing will be discarded")
    }

    //Get Current Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        geoCoder.reverseGeocodeLocation(location)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            if (!self.locationFound){
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString
                {
                    self.cityField.text = city as String + ", " + placeMark.administrativeArea!
                    self.loadLocation()
                }
                self.locationFound = true
            }
        }
    }
    
    func loadLocation(){
        mapView.removeAnnotations(mapView.annotations)
        let location: String = cityField.text!
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

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIApplication.sharedApplication().statusBarHidden = false
        
        if (segue.identifier == "NextInfoSegue"){
            if(previousScreen == "EditView"){
                let details : Details = segue.destinationViewController as! Details
                details.editType = editType
                details.previousScreen = "EditView"
                details.pickedImage = pickedImage
                details.pickedTitle = pickedTitle
                details.pickedLocation = cityField.text!
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
                details.pickedLocation = cityField.text!
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
