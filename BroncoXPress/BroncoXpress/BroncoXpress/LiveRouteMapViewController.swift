//
//  LiveRouteMapViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/29/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class LiveRouteMapsViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var theMap: MKMapView!
    
    @IBOutlet weak var routeNameLabel: UILabel!
    let locationManager = CLLocationManager()
    
    let region = CLBeaconRegion(proximityUUID:
        NSUUID(UUIDString:  "B9407F30-F5F8-466E-AFF9-25556B57FE6D" )!,
        identifier: "Estimotes")
    
    //    let purpleBeacon = CLBeaconRegion(proximityUUID:
    //        NSUUID(UUIDString:  "B9407F30-F5F8-466E-AFF9-25556B57FE6D" )!,
    //        major: 10294,
    //        minor: 22760,
    //        identifier: "Estimotes")
    //    let blueBeacon = CLBeaconRegion(proximityUUID:
    //        NSUUID(UUIDString:  "B9407F30-F5F8-466E-AFF9-25556B57FE6D" )!,
    //        major: 60727,
    //        minor: 5258,
    //        identifier: "Estimotes")
    //
    
    var colorGreen  =    UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0)
    var colorRed    =    UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    var colorBlue   =    UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0)
    var colorPurple =    UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0)
    let routes = [
        52587 : "Route A",
        22760 : "Route B2",
        35305 : "Route C"
    ]
    
    let colors = [
        "Route A" : UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0),
        "Route B1": UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0),
        "Route B2":  UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0),
        "Route C" : UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    ]
    
    
    let url = "http://www.broncoshuttle.com/Route/3164/Waypoints/"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        
        self.navigationController?.navigationBar.tintColor = colorGreen
        
        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse){
            
            
            // only user is using when detect beacon
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        locationManager.startRangingBeaconsInRegion(region)
        
        //
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        print(beacons)
        
        print("LiveRouteMap")
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        
        if(knownBeacons.count > 0){
            let closestBeacon = knownBeacons[0] as CLBeacon

//            self.navigationItem.title = self.routes[closestBeacon.minor.integerValue]
            self.routeNameLabel.text = self.routes[closestBeacon.minor.integerValue]
        
            self.routeNameLabel.tintColor = self.colors[self.routeNameLabel.text!]
            
            /* Passing detected Route to routeLatiLongJSON class for retriving Data from the Parse */
            
            //    let routeALatiLongJSON = RouteALatiLongJSON(beaconUUID: mintBeacon , min: 35305)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}