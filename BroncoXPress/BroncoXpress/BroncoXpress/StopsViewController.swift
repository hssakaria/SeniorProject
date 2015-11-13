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
    var stopName = String()
    var busStopsUrl = String()

    let colors = [
        "Route A" : UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0),
        "Route B1": UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0),
        "Route B2":  UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0),
        "Route C" : UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    ]

    override func viewDidLoad() {
        
        self.currentRouteName.title = currentRoute
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        makeQureyOnParse()
        
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
        
       nav?.barTintColor = self.colors[currentTitle]
      
        
    }
    
    
    
    func makeQureyOnParse(){
        
        
        let query = PFQuery(className: "BusStopsURL")
        query.whereKey("Routes", equalTo: currentRoute!)
        
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                print("Successfully retrieved: \(objects)")
                
                for object in objects!{
                    
                    self.busStopsUrl = object["Url"] as! String
                    
                    self.convertToNSUrlAndGetJSONData(self.busStopsUrl)
                    
                }
                
            } else {
//                print("Error: \(error) \(error!.userInfo)")
                self.showAlertMessage("Service is not available")

            }
        }
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    func convertToNSUrlAndGetJSONData(RouteUrl: String){
        
        if let url = NSURL(string: RouteUrl){
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                self.retriveJSONData(json)
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
                self.showAlertMessage("Anabled to connect to WebSerive.")

            }
            
            busStopsTableView.reloadData()
            
        }
        
    }
    /**************************************************************************************
     
     ***************************************************************************************/
    
    func retriveJSONData(json: JSON){
        
        var busStopsName = String()
        
        for busStops in json.arrayValue {
            
            busStopsName = busStops["Name"].stringValue
            busStopsArray.append(busStopsName)
        }
        
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func tableView(stopsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return busStopsArray.count
    }
    
    /**************************************************************************************
     Fill the table cell and assigned a color depending on their route name.
     ***************************************************************************************/
    
    override func tableView(stopsTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = stopsTableView.dequeueReusableCellWithIdentifier("BusStopsCell")
        
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
        let busArrivalTableViewController: BusArrivalTimesTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BusArrivalSBID") as! BusArrivalTimesTableViewController
        
        busArrivalTableViewController.currentStop = stopName
        
        
    }
    /**************************************************************************************
    Pass data (currentStop and currentRoute) to BusArrivalTimesTableViewController.
     ***************************************************************************************/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "busArrivalSegue" {
            
            let cell = sender as! UITableViewCell
            
            if let indexPath = tableView.indexPathForCell(cell) {
                
                let arrivalController = segue.destinationViewController as! BusArrivalTimesTableViewController
                arrivalController.currentStop = busStopsArray[indexPath.row]
                arrivalController.currentRoute = currentRoute
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            
            
            
        }
        
    }
    
    /**************************************************************************************
     Show Alert message.
     ***************************************************************************************/
    
    func showAlertMessage(errorMessage: String){
        
        let alertView = UIAlertController(title: "Message", message: errorMessage, preferredStyle: .Alert)
        let okResponse = UIAlertAction(title: "Ok", style: .Default){
            UIAlertAction in
            let routesController = self.navigationController?.viewDidAppear(true) as! RoutesController
            
            self.navigationController?.popToViewController(routesController , animated: true)
            //            self.performSegueWithIdentifier("RouteStopsSBID", sender: self)
        }
        
        alertView.addAction(okResponse)
        presentViewController(alertView, animated: true, completion: nil)
        
        
        
    }
    
   }

