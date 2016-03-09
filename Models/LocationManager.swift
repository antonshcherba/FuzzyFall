//
//  LocationManager.swift
//  FuzzyFall
//
//  Created by Admin on 05/03/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    func requestPermissions() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .NotDetermined, .Denied:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func findCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .NotDetermined,.Denied:
            return
        default:
            break
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(error)\n\(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let newLocation = locations.last!
        
        print("Longtitude^ \(newLocation.coordinate.longitude)")
        print("Longtitude^ \(newLocation.coordinate.latitude)")
        
        locationStringFrom(newLocation)
    }
    
    func locationStringFrom(location: CLLocation) {
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error == nil && placemarks?.count > 0 {
                let placemark = placemarks!.last!
                
                var locationString = "Location:\n"
                
                if let country = placemark.country {
                    locationString += "Country: \(country)\n"
                }
                
                if let area = placemark.administrativeArea {
                    locationString += "Area: \(area)\n"
                }
                
                if let locality = placemark.locality {
                    locationString += "City: \(locality)\n"
                }
                
                if let thoroughfare = placemark.thoroughfare, let subThoroughfare = placemark.subThoroughfare {
                    locationString += "Address: \(thoroughfare),\(subThoroughfare)\n"
                }
                
                locationString += "http://maps.apple.com/?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)\n"
                
                NSNotificationCenter.defaultCenter().postNotificationName(kNotification.foundLocation,
                    object: nil, userInfo: ["location": location, "locationString": locationString])
                
            } else {
                print("\(error.debugDescription)")
            }
        }
    }
}