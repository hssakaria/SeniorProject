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
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var routeNameArray = [String]()
    var stopNameArray = [String]()
    var vehicleLatiArray = [Double]()
    var vehicleLongArray = [Double]()
    var vehicleName = [String]()
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
        
    }
    
    @IBAction func refreshBarBtn(sender: UIBarButtonItem) {
        
        locationManager.startRangingBeaconsInRegion(region)
        //        locationManager.startUpdatingLocation()
        
        
    }
    /**************************************************************************************
     Set the map region. Center is CPP's latitude and longtitude
     ***************************************************************************************/
    
    func zoomToRegion(){
        
        let CPPLocation = CLLocationCoordinate2D(latitude: cppLatitude, longitude: cppLongtitude)
        let mapSpan = MKCoordinateSpanMake(0.02, 0.02)
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
                
                /* Passing detected Route to routeLatiLongJSON class for retriving Data from the Parse */
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
                
                self.getJSONDataForAnnotationOrPolylineOrLiveMap(json, Id: "stopLatiLong")
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
                
                self.getJSONDataForAnnotationOrPolylineOrLiveMap(json, Id: "routeLatiLong")
                
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
     This function pass the routeurl to JSON for Live Map Data------------------recall this function for upate.
     ***************************************************************************************/
    
    func passURLtoJSONforLiveMap(vahicleUrl: String){
        
        
        if let url = NSURL(string: vahicleUrl){
            
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json2 = JSON(data: data)
                
                self.getJSONDataForAnnotationOrPolylineOrLiveMap(json2, Id: "vehicleLatiLong")
                
                
                print("----json--> \(json2)")
                
                self.locationManager.stopRangingBeaconsInRegion(region)
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
                
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
     According the give ID, this function will retrive the data from JSON object and stores
     into associated array.
     ***************************************************************************************/
    
    func getJSONDataForAnnotationOrPolylineOrLiveMap(json: JSON, Id: String){
        
        
        if Id == "stopLatiLong" {
            
            var stopLatitude = Double()
            var stopLongitude = Double()
            var stop = String()
            
            for stopData in json.arrayValue{
                
                stopLatitude = stopData["Latitude"].doubleValue
                stopLongitude = stopData["Longitude"].doubleValue
                stop = stopData["Name"].stringValue
                
                stoplatitudeArray.append(stopLatitude)
                stoplongitudeArray.append(stopLongitude)
                stopNameArray.append(stop)
                
            }
            
            
            createAnnotation(
                stoplatitudeArray,
                longtitudeArray: stoplongitudeArray,
                stopNameArray: stopNameArray)
            
        }
        
        if Id == "routeLatiLong" {
            
            var latitude = Double()
            var longitude = Double()
            
            for stopData in json[0].arrayValue{
                
                latitude = stopData["Latitude"].doubleValue
                longitude = stopData["Longitude"].doubleValue
                
                latitudeArray.append(latitude)
                longitudeArray.append(longitude)
                
            }
            createPolyLine(latitudeArray,longtitudeArray: longitudeArray)
            
        }
        if Id == "vehicleLatiLong" {
            
            var latitude = Double()
            var longitude = Double()
            var name = String()
            
            for vehicleData in json.arrayValue{
                
                latitude = vehicleData["Latitude"].doubleValue
                longitude = vehicleData["Longitude"].doubleValue
                name = vehicleData["Name"].stringValue
                vehicleLatiArray.append(latitude)
                vehicleLongArray.append(longitude)
                vehicleName.append(name)
                
                createLiveMap(name, latitude: latitude, longtitude: longitude)
                
            }
            
        }
        
    }
    
    
    /**************************************************************************************
     This function will put annotation and title accourding to detected stop's Latitude and
     Longtitude.
     ***************************************************************************************/
    
    func createAnnotation(latitudeArray: [Double], longtitudeArray: [Double], stopNameArray: [String]){
        
        
        for var index = 0; index < latitudeArray.count; index++ {
            
            let location = CLLocationCoordinate2DMake(latitudeArray[index], longtitudeArray[index])
            
            let makeAnnotation = MakeAnnotation(title: stopNameArray[index] , subtitle: "", coordinate: location)
            theMap.addAnnotation(makeAnnotation)
            
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
     This function will draw a polyline accourding to detected route's Latitude and Longtitude
     ***************************************************************************************/
     
     //    func  createLiveMap(latitudeArray: [Double],longtitudeArray: [Double]){
    
    func  createLiveMap(name: String, latitude: Double,longtitude: Double){
        
        
        let annotation = CLLocationCoordinate2DMake(latitude, longtitude)
        
        
        let makeAnnotation = CustomAnnotation(title: name, coordinate: annotation)
        
   // here remove previous annotation. then add a new one
        
        
    theMap.addAnnotation(makeAnnotation)
        
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
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView {
            
            let busPinId = "busPin"
            let stopsPinId = "pin"
            let cppPinId = "cpp"
            
            var cppPin = mapView.dequeueReusableAnnotationViewWithIdentifier(cppPinId)
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(stopsPinId) as? MKPinAnnotationView
            var busPin = mapView.dequeueReusableAnnotationViewWithIdentifier(busPinId)
         

            
            if annotation.isKindOfClass(MakeAnnotation.self){
               
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: stopsPinId)
                pin!.canShowCallout = true
                pin!.animatesDrop = true
                pin!.tintColor = UIColor.darkGrayColor()
                //                pin.pinTintColor = self.colors[self.titleNavigate.title!]
                return pin!
            }
            
            
            //           if busView == nil {
            if annotation.isKindOfClass(CustomAnnotation.self){
                
                theMap.removeAnnotation(annotation)

                busPin = MKAnnotationView(annotation: annotation, reuseIdentifier: busPinId)
                busPin?.image = UIImage(named: "iCON_29.png")
                return busPin!
                
                
            }
            if annotation.isKindOfClass(CPPAnnotation.self) {
                cppPin = MKAnnotationView(annotation: annotation, reuseIdentifier: cppPinId)
                cppPin?.canShowCallout = true
                
                cppPin?.image = UIImage(named: "cpp.gif")
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
