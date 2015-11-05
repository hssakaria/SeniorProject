//
//  StopsViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/20/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//
/**************************************************************************************

***************************************************************************************/

import Foundation
import UIKit
import SwiftyJSON


class StopsViewController: UITableViewController{
    
    @IBOutlet var currentRouteName: UINavigationItem!
    @IBOutlet var busStopsTableView: UITableView!
    var selectedIndexPath: NSIndexPath?
    
    @IBOutlet var busStopsNavigationBar: UINavigationItem!
    var currentRoute: String?
    var busStopsArray = [String]()
    var numberOfRows = 0
    var stopName = String()
    var busStopsUrl = String()
    
    var colorGreen = UIColor(red: 0.1333, green: 0.4275, blue: 0, alpha: 1.0)
    var colorBlue = UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0)
    var colorRed = UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    var colorPurple = UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0)
    var colorBlack = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
    
    
    override func viewDidLoad() {
        
        self.currentRouteName.title = currentRoute
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        parseJSON()
        
    }
    /**************************************************************************************
     This function will change the navigation bar background color and text color.
     ***************************************************************************************/
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackOpaque
        
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.tintColor = UIColor.whiteColor()
        let currentTitle: String = currentRouteName.title!
        
        
        if currentTitle == "Route A"{
            nav?.barTintColor = colorRed
            
        }
        else if currentRoute == "Route B1 "{
            nav?.barTintColor = colorGreen
        }
        else if currentRoute == "Route B2"{
            nav?.barTintColor = colorPurple
        }
        else if currentRoute == "Route C"{
            nav?.barTintColor = colorBlue
        }
        else{
            nav?.barTintColor = colorBlack
            
        }
        
        
    }
    
    
    func parseJSON(){
        
        
        let query = PFQuery(className: "BusStopsURL")
        query.whereKey("Routes", equalTo: currentRoute!)
        
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                print("Successfully retrieved: \(objects)")
                
                for object in objects!{
                    
                    self.busStopsUrl = object["Url"] as! String
                    
                    self.passURLtoJSON(self.busStopsUrl)
                    
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
            
            busStopsTableView.reloadData()
            
        }
        
    }
    /**************************************************************************************
     
     ***************************************************************************************/
    
    func getJSONData(json: JSON){
        
        var busStopsName = String()
        
        for busStops in json.arrayValue {
            
            busStopsName = busStops["Name"].stringValue
            busStopsArray.append(busStopsName)
            numberOfRows = busStopsArray.count
        }
        
        //        print(busStopsArray)
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func tableView(stopsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numberOfRows
    }
    
    /**************************************************************************************
     Fill the table cell and assigned a color depending on their route name.
     ***************************************************************************************/
    
    override func tableView(stopsTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = stopsTableView.dequeueReusableCellWithIdentifier("BusStopsCell")
        cell?.textLabel?.textColor = colorBlack
        
        /********************************************************************
        Cell display the text from routesArray that contains data from Web.
        *********************************************************************/
        
        if busStopsArray.count != 0 {
            
            cell!.textLabel?.text  = busStopsArray[indexPath.row]
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        stopName = busStopsArray[indexPath.row]
        let busArrivalTableViewController: BusArrivalTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BusArrivalSBID") as! BusArrivalTableViewController
        
        busArrivalTableViewController.currentStop = stopName
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "busArrivalSegue" {
            
            let cell = sender as! UITableViewCell
            
            if let indexPath = tableView.indexPathForCell(cell) {
                
                let arrivalController = segue.destinationViewController as! BusArrivalTableViewController
                arrivalController.currentStop = busStopsArray[indexPath.row]
                arrivalController.currentRoute = currentRoute
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            
            
            
        }
        
    }
    
}

