//
//  ViewController.swift
//  TripPlanner
//
//  Created by Ronnie Wang on 2/28/18.
//  Copyright © 2018 DeAnza. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps
import GooglePlaces

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //OUTLETS
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBOutlet weak var datePickerView: UIPickerView!
    
    @IBOutlet weak var navigationButton: UIButton!
    
    @IBOutlet weak var lengthPickerView: UIPickerView!
    
    @IBOutlet weak var locationInput: UITextField!
    
    //VARIABLES
    var locationManager = CLLocationManager()
    let startDate = ["Today", "Tomorrow"]
    let length = ["1", "2", "3", "4", "5"]
    var marker = GMSMarker()
    //var placeLatitude : CLLocationDegrees = -33.86
    //var placeLongitude : CLLocationDegrees = 151.20
    var begin = "Today"
    var days = 3

    var placeLatitude : CLLocationDegrees = 37.3195
    var placeLongitude : CLLocationDegrees = 122.0451
    
    //FUNCTIONS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 1){
            return "\(startDate[row])"
        }
        else{
            return "\(length[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countrows: Int
        if(pickerView.tag == 1){
            countrows = startDate.count
        }
        else{
            countrows = length.count
        }
        return countrows
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 1){
            begin = startDate[row]
        }
        if(pickerView.tag == 2){
            days = Int(length[row])!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        locationManager.requestWhenInUseAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            let currentLocation = locationManager.location
            placeLatitude = currentLocation!.coordinate.latitude
            placeLongitude = currentLocation!.coordinate.longitude
        }
        
        initGoogleMaps()

        datePickerView.selectRow(0, inComponent: 0, animated: true)
        lengthPickerView.selectRow(2, inComponent: 0, animated: true)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initGoogleMaps(){
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.setMinZoom(5, maxZoom: 20)
        mapView.animate(toBearing: 0)
        mapView.isMyLocationEnabled = true
        self.googleMapView.camera = camera
        
        self.googleMapView.delegate = self
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.settings.myLocationButton = true
        
        // Creates a marker in the center of the map.

        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = googleMapView
    }
    
    //CLLocation Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 10.0)
        
        self.googleMapView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    
    //GMSMapView Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // self.googleMapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //self.googleMapView.isMyLocationEnabled = true
        /*
        if(gesture){
            mapView.selectedMarker = nil
        }
        */
    }
    
    //Google auto complete delegate
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let position1 = place.coordinate
        self.marker = GMSMarker(position: position1)
        
        self.marker.title = place.name
        self.marker.map = self.googleMapView
        
        placeLatitude = place.coordinate.latitude
        placeLongitude = place.coordinate.longitude
        
        let camera1: GMSCameraPosition? = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 12)
        
        self.googleMapView.camera = camera1!
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error while auto complete \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //ACTION
    @IBAction func openSearchBar(_ sender: UIBarButtonItem) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSegue" {
            let searchVC = segue.destination as! SearchViewController
            searchVC.latitude = placeLatitude
            searchVC.longitude = placeLongitude
            searchVC.begin = begin
            searchVC.days = days
        }
    }

    
}

