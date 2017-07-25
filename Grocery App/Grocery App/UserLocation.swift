//
//  locationManager.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/20/17.
//  Copyright © 2017 tko. All rights reserved.
//

import Foundation
import CoreLocation

class UserLocation {
    static let sharedInstance = UserLocation()
    let locationManager: CLLocationManager
    
    
    private init(){
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func getCurrentLocation() -> CLLocation{
        return(locationManager.location)!
    }
    
    func getZipCodeCoordinates (zip_code: String, completion: @escaping (Bool, CLLocation) -> Void ) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(zip_code) { (placemarks, error) in
            if error != nil {
                print(error?.localizedDescription ?? "cant get geocode")
            } else {
                if let placemarks = placemarks?[0] {
                    let location = placemarks.location
                    completion(true, location!)
                    
                }
            }
        }
    
        
    }
    
}
