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
    var busArrivalTimeArray = [String]()
    var numberOfRows = 0
    var busArrivalTimeURL = String()
    
    var currentTime = String()
    var arrivalTime = String()
    var busRouteNumber = String()
    
    override func viewDidLoad() {
        
        
        self.currentStopName.title = currentStop
        print(currentStop)
        parseJSON()
        
        
        
    }
    
    
    func parseJSON(){
        
        let query = PFQuery(className: "RouteAStops")
        
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
        
        var predictionTime = String()
        var busName = String()
        var arrivalTime = String()
//        var busSchedual = [[String: String]]()
        
        for busArrival in json["Predictions"].arrayValue {
            
            predictionTime = busArrival["PredictionTime"].stringValue
            busName = busArrival["BusName"].stringValue
            arrivalTime = busArrival["ArriveTime"].stringValue
            
            busArrivalTimeArray.append( predictionTime)
            busArrivalTimeArray.append( busName)
            busArrivalTimeArray.append( arrivalTime)
            numberOfRows = busArrivalTimeArray.count
        }
        
                print(busArrivalTimeArray)
        
    }
}

