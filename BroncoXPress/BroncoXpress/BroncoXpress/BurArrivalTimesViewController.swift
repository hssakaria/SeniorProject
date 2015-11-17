//
//  BurArrivalTimesViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 11/10/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//
/**************************************************************************************

***************************************************************************************/

import Foundation


import Foundation
import UIKit
import SwiftyJSON

class BusArrivalTimesTableViewController: UITableViewController{
    
    var timer = NSTimer()
    
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
        "Route B1 ": "RouteB1Stops",
        "Route B2": "RouteB2Stops",
        "Route C" : "RouteCStops"
    ]
    
    let availableServices = [
        "Route A" : "Monday - Thursday 7:30am to 11pm, Friday - 7:30am to 6:00pm",
        "Route B1 ": "Monday - Thursday 7:30am to 8:30pm, Friday - 7:30am to 2:00pm",
        "Route B2": "Monday - Thursday 7:30am to 8:30pm, Friday - 7:30am to 2:00pm",
        "Route C" : "Monday - Thursday 7:30am to 8:30pm, Friday - 7:30am to 2:00pm"
    ]
    
    override func viewDidLoad() {
        
        self.currentStopName.title = currentStop
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    override func viewDidAppear(animated: Bool) {
        
        loadData()
        
    }
    
    /**************************************************************************************
     This function returns the number of rows required to fill each cell, which in our case
     is the size of busArrivalTimeArray.
     ***************************************************************************************/
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        //        var count = 0
        //        if busArrivalTimeArray.count == 0 {
        //             let cell = tableView.dequeueReusableCellWithIdentifier("BusArrivalCell")
        //            cell?.textLabel?.text = "fadsfasd"
        //
        //            showAlertMessage("There are no arrival predictions at this time.", currentRoute: currentRoute!)
        //
        //        }
        //        else{
        //            count = busArrivalTimeArray.count
        //        }
        return busArrivalTimeArray.count
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "BusArrivalCell")
        
        /********************************************************************
        Cell display the text from routesArray that contains data from Web.
        *********************************************************************/
        
        if self.busArrivalTimeArray.count != 0 {
            
            cell.textLabel?.text  = busInfoArray[indexPath.row]
            cell.detailTextLabel?.text = busArrivalTimeArray[indexPath.row]
            
            
        }
        
        return cell
        
    }
    
    func update(){
        
        convertURLIntoJSON(busArrivalTimeURL)
        
    }
    
    func showAlertMessage(titleMessage: String, currentRoute: String){
        
        let  errorMessage = availableServices[currentRoute]!
        
        let alertView = UIAlertController(title: titleMessage, message: errorMessage, preferredStyle: .Alert)
        let okResponse = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alertView.addAction(okResponse)
        presentViewController(alertView, animated: true, completion: nil)
        
        
    }
    
}


private extension BusArrivalTimesTableViewController {
    
    
    func loadData(){
        
        
        let parseClassName  = self.parseClassName[currentRoute!]!
        
        if parseClassName !=  "" {
            
            makeQueryToParse(parseClassName)
        } else {
            
            showAlertMessage("Enable to connect to database.",currentRoute: currentRoute!)
        }
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    func makeQueryToParse(parseClassName: String){
        
        let query = PFQuery(className: parseClassName)
        
        query.whereKey("BusStopName", equalTo: currentStop!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                
                for object in objects!{
                    
                    self.busArrivalTimeURL = object["ArrivalTimeURL"] as! String
                    
                    self.convertURLIntoJSON(self.busArrivalTimeURL)
                    
                }
                
            } else {
                print("Error: \(error) \(error!.userInfo)")
                
                
                //                self.showAlertMessage("Enable to connect to websevice.", currentRoute: "")
                
                self.showAlertMessage( String(error?.userInfo), currentRoute: "")
            }
        }
        
    }
    /**************************************************************************************
     
     ***************************************************************************************/
    
    func convertURLIntoJSON(busArrivalTimeURL: String){
        
        if let url = NSURL(string: busArrivalTimeURL){
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                self.retriveJSONData(json)
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
            }
        }
        
        busArrivalTableView.reloadData()
        
    }
    
    
    
    func retriveJSONData(json: JSON){
        
        //                var predictionTime = String()
        var busName = String()
        var arrivalTime = String()
        var routeName = String()
        var minsLeft = String()
        
        
        for busArrival in json["Predictions"].arrayValue {
            
            routeName = busArrival["RouteName"].stringValue
            minsLeft = busArrival["Minutes"].stringValue
            busName = busArrival["BusName"].stringValue
            arrivalTime = busArrival["ArriveTime"].stringValue
            busInfoArray.append(" \(routeName ):   Bus \(busName )       \(minsLeft) mins")
            busArrivalTimeArray.append("@ \( arrivalTime)")
        }
        
    }
    
    
}
