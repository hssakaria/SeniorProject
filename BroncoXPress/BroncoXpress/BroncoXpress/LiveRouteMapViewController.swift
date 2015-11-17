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
    
    @IBOutlet weak var titleNavigate: UINavigationItem!
    //    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    
    @IBOutlet weak var theMap: MKMapView!
    
    var coordinatesData = RetriveCoordinatesFromJSON()
    var name = RetriveDataFromJSON()
    var arrivaldata = BusArrivalTableViewController()
    
    var timer = NSTimer()
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
    var stoplongitudeArray = [Double]()
    var polyLineLatitudeArray = [Double]()
    var polyLineLongitudeArray = [Double]()
    var routeNameArray = [String]()
    var stopNameArray = [String]()
    var vehicleLatiArray = [Double]()
    var vehicleLongArray = [Double]()
    var vehicleNameArray = [String]()
    var vehicleHeadingArray = [String]()
    let cppLatitude =  34.0564
    let cppLongtitude =   -117.8217
    
    
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
        "Route B1 ": UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0),
        "Route B2": UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0),
        "Route C" : UIColor(red: 0.99, green: 0.50, blue: 0, alpha: 1.0)
    ]
    
    let headingTo = [
                    ("N"):    UIImage(named: "busPin_N.gif"),
                    ("S"):    UIImage(named: "busPin_S.gif"),
                    ("E"):    UIImage(named: "busPin_E.gif"),
                    ("W"):    UIImage(named: "busPin_W.gif"),
                    ("NE"):   UIImage(named: "busPin_NE.gif"),
                    ("NW"):   UIImage(named: "busPin_NW.gif"),
                    ("SE"):   UIImage(named: "busPin_SE.gif"),
                    ("SW"):   UIImage(named: "busPin_SW.gif")]
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
        self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func refreshBarBtn(sender: UIBarButtonItem) {
        
        locationManager.startRangingBeaconsInRegion(region)
        update()
        
    }
    /**************************************************************************************
     Set the map region. Center is CPP's latitude and longtitude
     ***************************************************************************************/
    
    func zoomToRegion(){
        
        let CPPLocation = CLLocationCoordinate2D(latitude: cppLatitude, longitude: cppLongtitude)
        let mapSpan = MKCoordinateSpanMake(0.03, 0.03)
        let mapRegion = MKCoordinateRegionMake(CPPLocation, mapSpan)
        
        self.theMap.setRegion(mapRegion, animated: true)
        
        let annotation = CPPAnnotation(title: "Cal Poly Pomona",
            subtitle: "3801 W. Temple Ave. CA 91768 (909) 869 - 7659", coordinate: CPPLocation)
        
        
        theMap.addAnnotation(annotation)
        
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
                
                locationManager.startUpdatingLocation()
                
                self.getURLFromParseForAnnotationAndPolylineAndLiveMap(self.titleNavigate.title!)
                theMap.showsUserLocation = true
            }
            
    }
    /**************************************************************************************
     LocationManager cannot detect the beacon, It will show an alert contorller to select
     route.
     ***************************************************************************************/
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        
        showAlertControllerToHandleRoutes()
        
    }
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
    
    /**************************************************************************************
     This function will put annotation and title accourding to detected stop's Latitude and
     Longtitude.
     ***************************************************************************************/
    
    func locationManager(manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        
        self.passURLtoJSONforLiveMap(self.vehicleUrl)
        
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        let loadLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        
      
        theMap.centerCoordinate = loadLocation
        theMap.showsUserLocation = true
        
        locationManager.stopUpdatingLocation()
        
        
    }
    
    func showAction(routeTitle: String){
        
        
        self.getURLFromParseForAnnotationAndPolylineAndLiveMap(routeTitle)
        self.titleNavigate.title  = routeTitle
        
        
    }
    @IBAction func routeSegmentedControll(sender: UISegmentedControl) {
        
        
        let routeSeleted = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        
        locationManager.startUpdatingLocation()
        
        self.getURLFromParseForAnnotationAndPolylineAndLiveMap(routeSeleted!)
        
        
        
    }
    /**************************************************************************************
     This function will query urls from the Parse. The class name is BusStopURL that contains
     url for the stop's latitude and longtitude (for Annotation) and route's latitude and
     longtitude (for Polyline).
     ***************************************************************************************/
    
    func getURLFromParseForAnnotationAndPolylineAndLiveMap(routeName: String){
        
        let query = PFQuery(className: "BusStopsURL")
        
        query.whereKey("Routes", equalTo: routeName)
        
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                
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
                
                
                stoplatitudeArray = coordinatesData.fromJSONToPoints(json, Latitude: "Latitude")
                stoplongitudeArray = coordinatesData.fromJSONToPoints(json, Latitude: "Longitude")
                stopNameArray = name.fromJSON(json)
                
                createAnnotation(
                    stoplatitudeArray,
                    longtitudeArray: stoplongitudeArray,
                    stopNameArray: stopNameArray)
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
                
                //                let alertView = UIAlertController(title: "Error", message: "Couldnt load Bus Stops data", preferredStyle: .Alert)
                //                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                //                presentViewController(alertView, animated: true, completion: nil)
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
                
                polyLineLatitudeArray = coordinatesData.fromJSONToPolyLine(json, Latitude: "Latitude")
                polyLineLongitudeArray = coordinatesData.fromJSONToPolyLine(json, Latitude: "Longitude")
                
                createPolyLine(polyLineLatitudeArray, polyLineLongitudeArray: polyLineLongitudeArray)
                
                self.locationManager.stopRangingBeaconsInRegion(region)
                
            }
            else{
                
                NSLog("Enabled to format JSON data")
                
                //                let alertView = UIAlertController(title: "Error", message: "Enabled to format JSON data", preferredStyle: .Alert)
                //                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                //                presentViewController(alertView, animated: true, completion: nil)
            }
        }
        
    }
    /**************************************************************************************
     This function pass the routeurl to JSON for Live Map Data.
     NATimer will recall "update()" function to retrive vahicle's latitude and longitude
     every 2 seconds.
     ***************************************************************************************/
    
    func passURLtoJSONforLiveMap(vahicleUrl: String){
        
        
        if let url = NSURL(string: vahicleUrl){
            
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                vehicleLatiArray = coordinatesData.fromJSONToPoints(json, Latitude: "Latitude")
                vehicleLongArray = coordinatesData.fromJSONToPoints(json, Latitude: "Longitude")
                vehicleHeadingArray = name.fromJSONgetHeading(json)
                vehicleNameArray = name.fromJSON(json)
                
                createLiveMap( vehicleNameArray, latitudeArray: vehicleLatiArray, longtitudeArray: vehicleLongArray, vehicleHeadingTo: vehicleHeadingArray)
                
                self.locationManager.stopRangingBeaconsInRegion(region)

            }
            else{
                
                NSLog("Enabled to detect vehicle")
            }
        }
        
    }
    
    func update(){
    
        passURLtoJSONforLiveMap(vehicleUrl)
        
    }
    
     /**************************************************************************************
     This function will put annotation and title accourding to detected stop's Latitude and
     Longtitude.
     ***************************************************************************************/
    
    func createAnnotation(latitudeArray: [Double], longtitudeArray: [Double], stopNameArray: [String]){
        
        
        for var index = 0; index < latitudeArray.count; index++ {
            
            let location = CLLocationCoordinate2DMake(latitudeArray[index], longtitudeArray[index])
            
            let makeAnnotation = PinAnnotation(title: stopNameArray[index] , subtitle: "", coordinate: location)
            theMap.addAnnotation(makeAnnotation)
            
        }
        
    }
    
    /**************************************************************************************
     This function will draw a polyline accourding to detected route's Latitude and Longtitude
     ***************************************************************************************/
     
     //    func  createPolyLine(latitudeArray: [Double],longtitudeArray: [Double]){
    func  createPolyLine(polyLineLatitudeArray: [Double], polyLineLongitudeArray: [Double]){
        
        
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        let annotations = MKPointAnnotation()
        
        
        for var index = 0; index < polyLineLatitudeArray.count; index++ {
            
            let annotation = CLLocationCoordinate2DMake(polyLineLatitudeArray[index], polyLineLongitudeArray[index])
            annotations.coordinate = annotation
            points.append(annotations.coordinate)
            
        }
        
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        theMap.addOverlay(polyline)
        
    }
    
    /**************************************************************************************
     This function will draw a polyline accourding to detected route's Latitude and Longtitude
     ***************************************************************************************/
    
    func  createLiveMap(name: [String], latitudeArray: [Double],longtitudeArray: [Double], vehicleHeadingTo: [String]){
        
        
        
        for var index = 0; index < latitudeArray.count; index++ {
            
            let annotation = CLLocationCoordinate2DMake(latitudeArray[index], longtitudeArray[index])
            
            let makeAnnotation = BusAnnotation(title: name[index], subtitle: vehicleHeadingTo[index], coordinate: annotation)
    

            
            // get the arrival time using seague 
            
            
            
            theMap.addAnnotation(makeAnnotation)

        }
        
    }
    
    
    /**************************************************************************************
    This function will render the map. Each route has its defined color with linewidth of 3.
    ***************************************************************************************/
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        if overlay is MKPolyline {
            
            let  polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.darkGrayColor()
            
            //            polylineRenderer.strokeColor = self.colors[self.titleNavigate.title!]
            
            polylineRenderer.lineWidth = 2
            return polylineRenderer
            
        }
        
        return MKOverlayRenderer()
    }
    
    
    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            
            let stopsPinId = "pin"
            let cppPinId   = "cpp"
            let busPinId   = "busPin"
            
            var cppPin = mapView.dequeueReusableAnnotationViewWithIdentifier(cppPinId) //as? MKPinAnnotationView
            var stopPin = mapView.dequeueReusableAnnotationViewWithIdentifier(stopsPinId) as? MKPinAnnotationView
            var busPin = mapView.dequeueReusableAnnotationViewWithIdentifier(busPinId)
            
            
            if annotation.isKindOfClass(PinAnnotation.self){
                
                stopPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: stopsPinId)
                stopPin!.canShowCallout = true
                stopPin!.animatesDrop = true
                //                stopPin!.tintColor = UIColor.darkGrayColor()
                stopPin!.pinTintColor = self.colors[self.titleNavigate.title!]
                return stopPin!
            }

            if annotation.isKindOfClass(BusAnnotation.self){
                
                let heading = annotation.subtitle
                
               self.theMap.removeAnnotation(annotation)
                
                busPin = MKAnnotationView(annotation: annotation, reuseIdentifier: busPinId)
                busPin?.canShowCallout = true
                busPin?.image = self.headingTo[heading!!]!
                return busPin!
                
                
            }
            if annotation.isKindOfClass(CPPAnnotation.self) {
                cppPin = MKAnnotationView(annotation: annotation, reuseIdentifier: cppPinId)
                cppPin?.canShowCallout = true
             
//                cppPin!.pinTintColor = UIColor.brownColor()
                
                                cppPin?.image = UIImage(named: "cppPin.gif")
                return cppPin!
            }
            return MKAnnotationView()
    }
    
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
/**************************************************************************************
 showAlertCotrollerToHandleRoutes display viewAlertController if beacon does no detect
 the route.
 ***************************************************************************************/

private extension LiveRouteMapsViewController {
    
    func showAlertControllerToHandleRoutes(){
        
        
        let alertController = UIAlertController(title: "Choose your route.",
            message: "System is anable to detect route.", preferredStyle: .Alert)
        
        let routeAAction = UIAlertAction(title: "Route A", style: .Default) {
            UIAlertAction in
            
            self.showAction(UIAlertAction.title!)
            
        }
        let routeB1Action = UIAlertAction(title: "Route B1", style: .Default) {
            UIAlertAction in
            self.showAction(UIAlertAction.title!)
            
        }
        
        let routeB2Action = UIAlertAction(title: "Route B2", style: .Default) {
            UIAlertAction in
            self.showAction(UIAlertAction.title!)
            
        }
        let routeCAction = UIAlertAction(title: "Route C", style: .Default) {
            UIAlertAction in
            
            self.showAction(UIAlertAction.title!)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            UIAlertAction in }
        
        alertController.view.tintColor = UIColor.blackColor()
        
        alertController.addAction(routeAAction)
        alertController.addAction(routeB1Action)
        alertController.addAction(routeB2Action)
        alertController.addAction(routeCAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true){}
        
    }
    
}
