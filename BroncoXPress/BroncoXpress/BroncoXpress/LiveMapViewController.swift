//
//  LiveMapVewController.swift
//  iBeaconTest
//
//  Created by Hetal Sakaria on 10/14/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//
/**************************************************************************************
Estimote Beacons
mint: UUID: b9407f30-f5f8-466e-aff9-255556b57fe6d , major: 53456, minor: 35305
purple: UUID: b9407f30-f5f8-466e-aff9-255556b57fe6d , major: 10294, minor: 22760
blue: UUID: b9407f30-f5f8-466e-aff9-255556b57fe6d , major: 60727, minor: 5258

***************************************************************************************/


import UIKit
import MapKit
import CoreLocation // for iBeacon

class LiveMapViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet var Map: MKMapView!
    
    var colorGreen = UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0)
    
    
    
    /**************************************************************************************
    
    ***************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        self.navigationController?.navigationBar.tintColor = colorGreen
        
        let location = CLLocationCoordinate2DMake(34.050893,117.820734)
        let span = MKCoordinateSpanMake(0.9,0.9)
        let busRegion = MKCoordinateRegionMake(location,span)
        Map.setRegion(busRegion, animated: true)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
    
        annotation.title = "Route C"
        
      Map.addAnnotation(annotation)

    }
    /**************************************************************************************
    
    ***************************************************************************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**************************************************************************************
    
    ***************************************************************************************/
    
}

//major:62901, minor:60822,(kontakt)
//major: 10004, Minor 54480 (black beacon)
