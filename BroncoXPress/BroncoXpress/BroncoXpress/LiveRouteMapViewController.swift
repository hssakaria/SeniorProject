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
import SwiftyJSON

class LiveRouteMapsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var titleNavigate: UINavigationItem!
    
    var polyline: MKPolyline?
    var coordinates: [CLLocationCoordinate2D] = []
    let locationManager = CLLocationManager()
    
    var stopsUrl = String()
    var routeUrl = String()
    
    var stoplatitudeArray = [Double]()
    var stoplongtitudeArray = [Double]()
    var latitudeArray = [Double]()
    var longtitudeArray = [Double]()
    var routeNameArray = [String]()
    var stopNameArray = [String]()
    
    let region = CLBeaconRegion(proximityUUID: NSUUID(
        UUIDString:  "B9407F30-F5F8-466E-AFF9-25556B57FE6D" )!,
        identifier: "Estimotes")
    
    
    var colorGreen  =    UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0)
    var colorRed    =    UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    var colorBlue   =    UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0)
    var colorPurple =    UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0)
    
    let routes = [
        52587 : "Route A",
        //need add one more beacon for route B1
        22760 : "Route B2",
        35305 : "Route C"
    ]
    
    let colors = [
        "Route A" : UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0),
        "Route B1": UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0),
        "Route B2":  UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0),
        "Route C" : UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    ]
    
    /**************************************************************************************
     When viewLoad, the navigation bar will change color accoring to route detected.
     and set the region for the map.
     ***************************************************************************************/
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = colorGreen
        zoomToRegion()
        
    }
    /**************************************************************************************
     When view appears, locationmanger will detect the region for the beacons.
     ***************************************************************************************/
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.delegate = self
        self.theMap.delegate = self
        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse){
            
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        locationManager.startRangingBeaconsInRegion(region)
        
    }
    
    /**************************************************************************************
     Set the map region. Center is CPP's latitude and longtitude
     ***************************************************************************************/
    
    func zoomToRegion(){
        
        let centerLocation = CLLocationCoordinate2DMake(34.058929, -117.818898)
        let mapSpan = MKCoordinateSpanMake(0.009, 0.009)
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        self.theMap.setRegion(mapRegion, animated: true)
    }
    
    /**************************************************************************************
     If locationManager did fail to locate the Beacon, then AlertView will display an error
     message.
     ***************************************************************************************/
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        UIAlertView(title: "Error",
            message: "Sorry, this run has no locations saved",
            delegate:nil,
            cancelButtonTitle: "OK").show()
        
        print("Location did fail to locate!")
    }
    /**************************************************************************************
     LocationManager will detect the beacon according its range and dislpay the closest one
     with its assiged RouteName.
     ***************************************************************************************/
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon],
        inRegion region: CLBeaconRegion) {
            
            let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
            
            if(knownBeacons.count > 0){
                
                let closestBeacon = knownBeacons[0] as CLBeacon
                
                self.titleNavigate.title = self.routes[closestBeacon.minor.integerValue]
                
                
                /* Passing detected Route to routeLatiLongJSON class for retriving Data from the Parse */
                
                self.getAnnotationAndPolyline(self.titleNavigate.title!)
                
            }
            
    }
    
    /**************************************************************************************
     This function will query urls from the Parse. The class name is BusStopURL that contains
     url for the stop's latitude and longtitude (for Annotation) and route's latitude and
     longtitude (for Polyline).
     ***************************************************************************************/
    
    func getAnnotationAndPolyline(routeName: String){
        
        let query = PFQuery(className: "BusStopsURL")
        query.whereKey("Routes", equalTo: routeName)
        
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                print("Successfully retrieved: \(objects)")
                
                for object in objects!{
                    
                    self.stopsUrl = object["Url"] as! String
                    self.routeUrl = object["RouteLatiLong"] as! String
                    
                    self.passURLtoJSONForAnnotation(self.stopsUrl)
                    self.passURLtoJSONForPolyline(self.routeUrl)
                    
                }
                
            } else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
        
    }
    
    /**************************************************************************************
     This function pass the stopurl to JSON for retrive Data
     ***************************************************************************************/
    
    func passURLtoJSONForAnnotation(StopsUrl: String){
        
        
        if let url = NSURL(string: StopsUrl){
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                self.getJSONDataForAnnotationOrPolyline(json, Id: "stopLatiLong")
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
            }
        }
        
    }
    
    /**************************************************************************************
     This function pass the routeurl to JSON for retrive Data
     ***************************************************************************************/
    
    func passURLtoJSONForPolyline(latiLongUrl: String){
        
        
        if let url = NSURL(string: latiLongUrl){
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                self.getJSONDataForAnnotationOrPolyline(json, Id: "routeLatiLong")
                
                //                self.getJSONDataForPolyline(json, Id: "routeLatiLong")
                
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
            }
        }
        
    }
    /**************************************************************************************
     According the give ID, this function will retrive the data from JSON object and stores
     into associated array.
     ***************************************************************************************/
    
    func getJSONDataForAnnotationOrPolyline(json: JSON, Id: String){
        
        
        if Id == "stopLatiLong" {
            
            var stopLatitude = Double()
            var stopLongitude = Double()
            var stop = String()
            
            for stopData in json.arrayValue{
                
                stopLatitude = stopData["Latitude"].doubleValue
                stopLongitude = stopData["Longitude"].doubleValue
                stop = stopData["Name"].stringValue
                
                stoplatitudeArray.append(stopLatitude)
                stoplongtitudeArray.append(stopLongitude)
                stopNameArray.append(stop)
                
            }
            
            createAnnotation(
                stoplatitudeArray,
                longtitudeArray: stoplongtitudeArray,
                stopNameArray: stopNameArray)
            
        }
        
        if Id == "routeLatiLong" {
            
            var latitude = Double()
            var longitude = Double()
                        
            for stopData in json[0].arrayValue{
                
                latitude = stopData["Latitude"].doubleValue
                longitude = stopData["Longitude"].doubleValue
                
                latitudeArray.append(latitude)
                longtitudeArray.append(longitude)
                
            }
            createPolyLine(latitudeArray,longtitudeArray: longtitudeArray)
            
        }
        
    }
    
    /**************************************************************************************
    This function will draw a polyline accourding to detected route's Latitude and Longtitude
     ***************************************************************************************/
    
    func  createPolyLine(latitudeArray: [Double],longtitudeArray: [Double]){
        
        
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        let annotations = MKPointAnnotation()
        
        for var index = 0; index < latitudeArray.count; index++ {
            
            let annotation = CLLocationCoordinate2DMake(latitudeArray[index], longtitudeArray[index])
            
            annotations.coordinate = annotation
            points.append(annotations.coordinate)
            
        }
        
        
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        theMap.addOverlay(polyline)
        
        
    }
    /**************************************************************************************
     This function will put annotation and title accourding to detected stop's Latitude and
     Longtitude.
     ***************************************************************************************/
    
    func createAnnotation(latitudeArray: [Double], longtitudeArray: [Double], stopNameArray: [String]){
        
        let annotations = MKPointAnnotation()
        
        for var index = 0; index < latitudeArray.count; index++ {
            
            let annotation = CLLocationCoordinate2DMake(latitudeArray[index], longtitudeArray[index])
            
            annotations.coordinate = annotation
            annotations.title = stopNameArray[index]
            theMap.addAnnotation(annotations)
            
        }
        
    }
    
    /**************************************************************************************
     This function will render the map. Each route has its defined color with linewidth of 3.
     ***************************************************************************************/
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        
        
        if overlay is MKPolyline {
            let  polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = self.colors[self.titleNavigate.title!]
            
            polylineRenderer.lineWidth = 3
            return polylineRenderer
            
        }
        return nil
    }
    
    /**************************************************************************************

     ***************************************************************************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}