//
//  LiveMapVewController.swift
//  iBeaconTest
//
//  Created by Hetal Sakaria on 10/14/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation // for iBeacon

class LiveMapViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet var Map: MKMapView!
    
    var color = UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0)
    
    let beaconRegion =
    CLBeaconRegion(proximityUUID: NSUUID(
        UUIDString: "F7826DA6-4FA2-4E98-8024-BC5B71E0893E" )!,
        identifier: "Kontakt")
    
    let beaconRegion2 = CLBeaconRegion(
        proximityUUID: NSUUID(
            UUIDString: "FDA50693-A4E2-4EB1-AFCF-C6EB07647825")!,
        identifier: "pBeacon")
    
    
    
    
    //    //
    //        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString:
    //            "F7826DA6-4FA2-4E98-8024-BC5B71E0893E" )!,
    //            major: 62901, minor: 60822, identifier: "Kontakt")
    //
    //
    //    let region = CLBeaconRegion(proximityUUID:
    //        NSUUID(UUIDString: "FDA50693-A4E2-4EB1-AFCF-C6EB07647825")!,
    //        identifier: "pBeacon")
    
    let url = "http://broncoshuttle.com/map"
    
    @IBOutlet weak var webView: UIWebView!
    
    // 60822 is a minor value of this beacon
    // 54480 is a minor value for black beacon
    
    let colors = [
        
        60822 : UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        
        54480 : UIColor(red: 44/255, green: 47/255, blue: 100/255, alpha: 1)
    ]
    
    //        let webURL = [
    //            60822: UIWebView(frame: <#T##CGRect#>)
    //        ]
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        self.navigationController?.navigationBar.tintColor = color
        
        
        let location = CLLocationCoordinate2DMake(34.050893,117.820734)
        let span = MKCoordinateSpanMake(0.9,0.9)
        let busRegion = MKCoordinateRegionMake(location,span)
        Map.setRegion(busRegion, animated: true)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
    
        annotation.title = "Route C"
        
      Map.addAnnotation(annotation)

        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse){
            
            
            // only user is using when detect beacon
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion2)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons:
        [CLBeacon], inRegion region: CLBeaconRegion) {
            
            
            print(beacons)
            
            print("Live Map Page loaded")
            // just to store only known Beacon into an array
            // so clear out all the unknown
            // proximity can be in range from 0 to 3
            // 0 means unknow.
            
            //
            let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
            
            if(knownBeacons.count > 0){
                let closestBeacon = knownBeacons[0] as CLBeacon
                
                self.view.backgroundColor = self.colors[closestBeacon.minor.integerValue]
                
                
                //                let requestURL = NSURL(string:url)
                //                let request = NSURLRequest(URL: requestURL!)
                //                webView.loadRequest(request)
                //                 self.webView.loadRequest(request)
            }
    }
    
}

//major:62901, minor:60822,(kontakt)
//major: 10004, Minor 54480 (black beacon)
