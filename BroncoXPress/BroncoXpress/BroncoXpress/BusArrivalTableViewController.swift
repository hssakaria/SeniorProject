//
//  BusArrivalTableViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/28/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class BusArrivalTableViewController: UITableViewController{
    
    
    
    @IBOutlet var currentStopName: UINavigationItem!
    @IBOutlet var busArrivalTableView: UITableView!
    var currentStop: String?
    var currentRoute: String?
    var busArrivalTimeArray = [String]()
    var numberOfRows = 0
    var busArrivalTimeURL = String()
    
    var currentTime = String()
    var arrivalTime = String()
    var busRouteNumber = String()
    
    override func viewDidLoad() {
        
        
        self.currentStopName.title = currentStop
        
        parseJSON()
        
    }
    
    
    func parseJSON(){
        
        var parseClassName = String()
        
        if currentRoute == "Route A" {
            
            parseClassName = "RouteAStops"
            
        }else if currentRoute == "Route B1 "{
            
            parseClassName = "RouteB1Stops"
            
        }else if currentRoute == "Route B2"{
            
            parseClassName = "RouteB2Stops"
            
        }else if currentRoute == "Route C"{
            
            parseClassName = "RouteCStops"
            
        }else{
            
            
            // display error message
        }
        
        makeQuery(parseClassName)
    }
    func makeQuery(parseClassName: String){
        
        let query = PFQuery(className: parseClassName)
        
        query.whereKey("BusStopName", equalTo: currentStop!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                
                print("Successfully retrieved: \(objects)")
                
                for object in objects!{
                    
                    self.busArrivalTimeURL = object["ArrivalTimeURL"] as! String
                    
                    self.passURLtoJSON(self.busArrivalTimeURL)
                    
                }
                
            } else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
        
        
        
        
    }
    /**************************************************************************************
    
    ***************************************************************************************/
    
    func passURLtoJSON(RouteUrl: String){
        
        if let url = NSURL(string: RouteUrl){
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                self.getJSONData(json)
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
            }
            
            busArrivalTableView.reloadData()
            
        }
        
    }
    /**************************************************************************************
    
    ***************************************************************************************/
    
    func getJSONData(json: JSON){
        
//                var predictionTime = String()
        var busName = String()
        var arrivalTime = String()
        var routeName = String()
        var minsLeft = String()
        
        
        for busArrival in json["Predictions"].arrayValue {
        
//        print("--- ")
            
//            predictionTime = busArrival["PredictionTime"].stringValue
            routeName = busArrival["RouteName"].stringValue
            minsLeft = busArrival["Minutes"].stringValue
            busName = busArrival["BusName"].stringValue
            arrivalTime = busArrival["ArriveTime"].stringValue
            
            busArrivalTimeArray.append(" \(routeName ):   Bus \(busName ) @ \( arrivalTime)")
            numberOfRows = busArrivalTimeArray.count
        }
        
        print(busArrivalTimeArray)
        
    }
    /**************************************************************************************
    
    ***************************************************************************************/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    /**************************************************************************************
    
    ***************************************************************************************/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusArrivalCell")
        
        /********************************************************************
        Cell display the text from routesArray that contains data from Web.
        *********************************************************************/
        //       let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: <#T##NSIndexPath#>) as UITableViewCell!
        
        if busArrivalTimeArray.count != 0 {
            cell!.textLabel?.text  = busArrivalTimeArray[indexPath.row]

        }
   
        return cell!
        
    }
    
    
    
}

