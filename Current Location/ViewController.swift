//
//  ViewController.swift
//  Current Location
//
//  Created by AdBox on 7/17/17.
//  Copyright © 2017 myth. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController{
    
    @IBOutlet weak var view_map: UIView!
    @IBOutlet weak var lb_currentPlaceAddress: UILabel!
    @IBOutlet weak var lb_currentPlaceName: UILabel!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var view_googleMap: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var nearbyPlaces: [GMSPlace] = []
    var selectedLocation: GMSPlace?
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)

    @IBAction func nearByPlacess(_ sender: Any) {
        self.performSegue(withIdentifier: "segue_showNearbyPlaces", sender: self)
    }
    
    @IBAction func unwindSegueViewOnMap(segue: UIStoryboardSegue){
    
        view_googleMap.clear()
 
        if selectedLocation != nil {
            
            let marker = GMSMarker(position: (self.selectedLocation?.coordinate)!)
            marker.title = selectedLocation?.name
            marker.snippet = selectedLocation?.formattedAddress
            marker.map = view_googleMap
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // Initialize map by default location 
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        
        view_googleMap = GMSMapView.map(withFrame: view_map.bounds, camera: camera)
        view_googleMap.settings.myLocationButton = true
        view_googleMap.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view_googleMap.isMyLocationEnabled = true
        view_googleMap.isHidden = true
        
        view_map.addSubview(view_googleMap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segue_showNearbyPlaces" {
        
            let vc = segue.destination as! NearbyPlacesTVC
            vc.places = self.nearbyPlaces
        }
    }

    // Populate the array with the list of likely places.
    func getNearbyPlaces() {
        
        // Clean up from previous sessions.
        self.nearbyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            
            if let error = error {
                
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                
                // get almost close place
                let currentPlace = likelihoodList.likelihoods.first
                // set place name and address
                if let name = currentPlace?.place.name, let address = currentPlace?.place.formattedAddress {
                    
                    self.lb_currentPlaceName.text = name
                    self.lb_currentPlaceAddress.text = address
                }
                
                // get all nearby placess and apend to array
                for likelihood in likelihoodList.likelihoods {
                    
                    let place = likelihood.place
                    if !self.nearbyPlaces.contains(place) {
                        self.nearbyPlaces.append(place)
                    }
                }
            }
        })
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
  
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if view_googleMap.isHidden {
            view_googleMap.isHidden = false
            view_googleMap.camera = camera
        } else {
            view_googleMap.animate(to: camera)
        }
        
        self.getNearbyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            view_googleMap.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
