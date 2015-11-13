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
    var busInfoArray = [String]()
    var numberOfRows = 0
    var busArrivalTimeURL = String()
    
    var currentTime = String()
    var arrivalTime = String()
    var busRouteNumber = String()
    
    let parseClassName = [
        "Route A" : "RouteAStops",
        "Route B1": "RouteB1Stops",
        "Route B2": "RouteB2Stops",
        "Route C" : "RouteCStops"
    ]
    
    override func viewDidLoad() {
        
        self.currentStopName.title = currentStop
        
        parseJSON()
        
    }
    
    func parseJSON(){
        
        //        var parseClassName = String()
        
        let parseClassName  = self.parseClassName[currentRoute!]!
        
        if parseClassName !=  "" {
            
            makeQuery(parseClassName)
        } else {
            
            
        }
        
    }
    
    func makeQuery(parseClassName: String){
        
        let query = PFQuery(className: parseClassName)
        
        query.whereKey("BusStopName", equalTo: currentStop!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                
                print("Successfully retrieved: \(objects)")
                
                for object in objects!{
                    
                    self.busArrivalTimeURL = object["ArrivalTimeURL"] as! String
                    
                    print(self.busArrivalTimeURL)
                    
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
            
            //            predictionTime = busArrival["PredictionTime"].stringValue
            routeName = busArrival["RouteName"].stringValue
            minsLeft = busArrival["Minutes"].stringValue
            busName = busArrival["BusName"].stringValue
            arrivalTime = busArrival["ArriveTime"].stringValue
            busInfoArray.append(" \(routeName ):   Bus \(busName )")
            busArrivalTimeArray.append("@ \( arrivalTime)")
            //            numberOfRows = busArrivalTimeArray.count
        }
        
    }
    /**************************************************************************************
     This function returns the number of rows required to fill each cell, which in our case
     is the size of busArrivalTimeArray.
     ***************************************************************************************/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return numberOfRows
        return busArrivalTimeArray.count
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //        let cell = tableView.dequeueReusableCellWithIdentifier("BusArrivalCell")
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "BusArrivalCell")
        //        let serviceNotAvailable: [String] = ["Service is not available"]
        /********************************************************************
        Cell display the text from routesArray that contains data from Web.
        *********************************************************************/
        //       let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: <#T##NSIndexPath#>) as UITableViewCell!
        
        if busArrivalTimeArray.count != 0 {
            
            //             cell.textLabel?.text = busArrivalTimeArray[indexPath.row]
            cell.textLabel?.text  = busInfoArray[indexPath.row]
            cell.detailTextLabel?.text = busArrivalTimeArray[indexPath.row]
            
            
        }
        //        if busArrivalTimeArray.count == 0 {
        //            cell!.textLabel?.text  = serviceNotAvailable[0]
        //
        //        }
        
        return cell
        
    }
    
    func getArrivalTime() -> [String] {
        busArrivalTimeArray = ["fsadfds", "fasdfasdfsd"]
        return busArrivalTimeArray
    }
    
}

