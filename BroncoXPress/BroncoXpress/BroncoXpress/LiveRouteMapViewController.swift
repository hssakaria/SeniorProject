//
//  LiveRouteMapViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/29/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

//Publish Key: pub-c-9d2b3702-02d0-45c7-a609-48ba8899c92a
//Subscribe Key: sub-c-aa68841c-83fa-11e5-8495-02ee2ddab7fe

import Foundation
import MapKit
import CoreLocation
import SwiftyJSON


class LiveRouteMapsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate{
    
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var titleNavigate: UINavigationItem!
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    
    var polyline: MKPolyline?
    var coordinates: [CLLocationCoordinate2D] = []
    let locationManager = CLLocationManager()
    var manager:CLLocationManager!
    
    var myLocations: [CLLocation] = []
    var vehicleLocation: [CLLocation] = []
    var stopsUrl = String()
    var routeUrl = String()
    var vehicleUrl = String()
    
    var stoplatitudeArray = [Double]()
    var stoplongtitudeArray = [Double]()
    var latitudeArray = [Double]()
    var longtitudeArray = [Double]()
    var routeNameArray = [String]()
    var stopNameArray = [String]()
    var vehicleLatiArray = [Double]()
    var vehicleLongArray = [Double]()
    let cppLatitude = 34.058929
    let cppLongtitude = -117.818898
    
    let region = CLBeaconRegion(proximityUUID: NSUUID(
        UUIDString:  "B9407F30-F5F8-466E-AFF9-25556B57FE6D" )!,
        identifier: "Estimotes")

    
    let routes = [
        52587 : "Route A",
        //need add one more beacon for route B1
        22760 : "Route B2",
        35305 : "Route C"
    ]
    
    let colors = [
        "Route A" : UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0),
        "Route B1": UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0),
        "Route B2": UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0),
        "Route C" : UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    ]
    
    /**************************************************************************************
     When viewLoad, the navigation bar will change color accoring to route detected.
     and set the region for the map.
     ***************************************************************************************/
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        zoomToRegion()
        
    }
    
    /**************************************************************************************
     When view appears, locationmanger will detect the region for the beacons.
     ***************************************************************************************/
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        locationManager.delegate = self
        self.theMap.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse){
            
            locationManager.requestWhenInUseAuthorization()
        }
     
        locationManager.startRangingBeaconsInRegion(region)
//        locationManager.startUpdatingLocation()

        
    }
    
    @IBAction func refreshBarBtn(sender: UIBarButtonItem) {
        
        locationManager.startRangingBeaconsInRegion(region)
//        locationManager.startUpdatingLocation()
        
    }
    /**************************************************************************************
     Set the map region. Center is CPP's latitude and longtitude
     ***************************************************************************************/
    
    func zoomToRegion(){
        
        let centerLocation = CLLocationCoordinate2DMake(cppLatitude, cppLongtitude)
        let mapSpan = MKCoordinateSpanMake(0.01, 0.01)
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        self.theMap.setRegion(mapRegion, animated: true)
        
//        
//        let annotations = MKPointAnnotation()
//        
//        annotations.coordinate = centerLocation
//        annotations.title = "CPP"
//        theMap.addAnnotation(annotations)

    }
    
    /**************************************************************************************
     If locationManager did fail to locate the Beacon, then AlertView will display an error
     message.
     ***************************************************************************************/
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
       
        UIAlertView(title: "Error",
            message: "Sorry, Enable to detect location",
            delegate:nil,
            cancelButtonTitle: "OK").show()
        
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
                locationManager.startUpdatingLocation()

                
                self.getAnnotationAndPolyline(self.titleNavigate.title!)
                theMap.showsUserLocation = true
            }
           
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
       
        UIAlertView(title: "Error",
            message: "Enbled to detect Beacon. \nPlease choose your route.",
            delegate:nil,
            cancelButtonTitle: "OK").show()
    }
    
    @IBAction func routeSegmentedControll(sender: UISegmentedControl) {
        
        
     let routeSeleted = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        
        locationManager.startUpdatingLocation()
        
        
        self.getAnnotationAndPolyline(routeSeleted!)
        
        
        
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
                    self.vehicleUrl = object["VehicleUrl"] as! String
                    
                    self.passURLtoJSONForAnnotation(self.stopsUrl)
                    self.passURLtoJSONForPolyline(self.routeUrl)
                    self.passURLtoJSONforLiveMap(self.vehicleUrl)
                    
                }
                
            } else {
                
                print("Error: \(error) \(error!.userInfo)")
                
                UIAlertView(title: "Error",
                    message: "Error: \(error) \(error!.userInfo)",
                    delegate:nil,
                    cancelButtonTitle: "OK").show()
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
                
                let alertView = UIAlertController(title: "Error", message: "Couldnt load Bus Stops data", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                presentViewController(alertView, animated: true, completion: nil)
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
            
                self.locationManager.stopRangingBeaconsInRegion(region)
            
            
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
                
                let alertView = UIAlertController(title: "Error", message: "Enabled to format JSON data", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                presentViewController(alertView, animated: true, completion: nil)
            }
        }
        
    }
    /**************************************************************************************
     This function pass the routeurl to JSON for Live Map Data
     ***************************************************************************************/
    
    func passURLtoJSONforLiveMap(vahicleUrl: String){
        
        
        if let url = NSURL(string: vahicleUrl){
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                self.getJSONDataForAnnotationOrPolyline(json, Id: "vehicleLatiLong")
                
                self.locationManager.stopRangingBeaconsInRegion(region)
                
                
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
                
                
                UIAlertView(title: "Error",
                    message: "Enabled to detect vehicle",
                    delegate:nil,
                    cancelButtonTitle: "OK").show()
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
            
            
            let busArrival = BusArrivalTableViewController()
            
            print("arrival:  \(busArrival.getArrivalTime())")
            
            
            let stops = StopsViewController()
            
            
            
            print("stops:  \(stops.getBusStops())")

            
            
            
            
            
            
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
        if Id == "vehicleLatiLong" {
            
            var latitude = Double()
            var longitude = Double()
            
            for stopData in json.arrayValue{
                
                latitude = stopData["Latitude"].doubleValue
                longitude = stopData["Longitude"].doubleValue
                
                vehicleLatiArray.append(latitude)
                vehicleLongArray.append(longitude)
                 print("liveMapPoints  \(latitude )")
                
//                vehicleLocation = CLLocation(latitude: latitude, longitude: longitude)
            }
    
            createLiveMap(latitudeArray,longtitudeArray: longtitudeArray)
            
        }

        
    }
    
    /**************************************************************************************
     This function will draw a polyline accourding to detected route's Latitude and Longtitude
     ***************************************************************************************/
    
    func  createLiveMap(latitudeArray: [Double],longtitudeArray: [Double]){
        
        
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        let annotations = MKPointAnnotation()
        
        for var index = 0; index < latitudeArray.count; index++ {
            
            let annotation = CLLocationCoordinate2DMake(latitudeArray[index], longtitudeArray[index])
            
            annotations.coordinate = annotation
            points.append(annotations.coordinate)
            
        }
        
        
//        let polyline = MKPolyline(coordinates: &points, count: points.count)
//        theMap.addOverlay(polyline)
        print("liveMapPoints  \(points)")

        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
      
        var locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
  
        
        
        
        
        
        
        let loadLocation = CLLocationCoordinate2D(latitude: 34.04789, longitude: -117.815475)
        
        print(loadLocation)
        theMap.centerCoordinate = loadLocation
        locationManager.stopUpdatingLocation()
        
//        myLocations.append(location[0] as CLLocation)
        
//        let spanX = 0.07
//        let spanY = 0.07
//        
//        let newRegion = MKCoordinateRegionMake(theMap.userLocation.coordinate, MKCoordinateSpanMake(spanX, spanY))
//        theMap.setRegion(newRegion, animated: true)
//        
////        
//        if (myLocations.count > 1){
//            var sourceIndex = myLocations.count - 1
//            var destinationIndex = myLocations.count - 2
//            
//            let c1 = myLocations[sourceIndex].coordinate
//            let c2 = myLocations[destinationIndex].coordinate
//            var a = [c1, c2]
//            var polyline = MKPolyline(coordinates: &a, count: a.count)
//            theMap.addOverlay(polyline)
//        }
//        
//        
        
        
        
    }
    
     
     /**************************************************************************************
     This function will put annotation and title accourding to detected stop's Latitude and
     Longtitude.       "Latitude": 34.04789,
     
     "Longitude": -117.815475,
     ***************************************************************************************/
    
    func createAnnotation(latitudeArray: [Double], longtitudeArray: [Double], stopNameArray: [String]){
        

        for var index = 0; index < latitudeArray.count; index++ {
            
            let location = CLLocationCoordinate2DMake(latitudeArray[index], longtitudeArray[index])
            let annotations = MKPointAnnotation()

            annotations.coordinate = location
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
    
    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            if annotation is MKUserLocation {
                //return nil so map view draws "blue dot" for standard user location
                return nil
            }
            
            let reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.animatesDrop = true
                pinView!.pinColor = .Purple
//                pinView!.pinTintColor = self.colors[self.titleNavigate.title!]
            }
            else {
                pinView!.annotation = annotation
            }
            
            return pinView
    }
    

    /**************************************************************************************

     ***************************************************************************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}