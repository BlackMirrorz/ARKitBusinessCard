//
//  MapView.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 12/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//---------------------------------
//MARK: - CLLocationManagerDelegate
//---------------------------------

extension MapView: CLLocationManagerDelegate{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //1. Get The Users Current Location
        guard let currentLocation = locations.last else { return }
        
        print("""
            User Latitude = \(currentLocation.coordinate.latitude)
            User Longtitude = \(currentLocation.coordinate.longitude)
            """)
        
        //2. Save The Address
        appUserLocation = (latitude: currentLocation.coordinate.latitude, longtitude: currentLocation.coordinate.longitude)
    }
    
}

class MapView: MKMapView{
    
    var locationManager: CLLocationManager!
    
    var latittude: Double!
    var longtitude: Double!
    
    var appUserLocation: (latitude: Double, longtitude: Double)?
    
    //-----------------------
    //MARK: - Intitialization
    //-----------------------
    
    init(frame: CGRect, latitude: Double, longtitude: Double){
        super.init(frame: frame)
        
        self.latittude = latitude
        self.longtitude = longtitude
        setupMapWith(latitude: self.latittude, longtitude: self.longtitude)
        setupUserLocation()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("MapView Coder Not Implemented") }
    
    //---------------
    //MARK: Map Setup
    //---------------
    
    /// Sets Up The MKMapView From The Specificed Latitiude & Longtitude
    ///
    /// - Parameters:
    ///   - latitude: Double
    ///   - longtitude: Double
    private func setupMapWith(latitude: Double, longtitude: Double){
        
        //1. Convert The Data To A CLLocation
        let landMarkLocation = CLLocation(latitude: latitude, longitude: longtitude)
        
        //2. Set The Desired Radius
        let regionRadius: CLLocationDistance = 750
        
        //3. Center The Location On The Map
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(landMarkLocation.coordinate, regionRadius, regionRadius)
        self.setRegion(coordinateRegion, animated: true)
    }
    
    /// Registers To Get The Users Current Location
    func setupUserLocation(){
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        
    }
    
}
