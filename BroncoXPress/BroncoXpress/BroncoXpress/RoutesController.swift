//
//  RoutesController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/21/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//
/**************************************************************************************

***************************************************************************************/

import UIKit
import SwiftyJSON


class RoutesController: UITableViewController, NSURLConnectionDelegate {
    
    var routesArray = [String]()
    
    var route = String()
    
    var routes = RetriveDataFromJSON()
    
    let colors = [
        0   : UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0),
        1   : UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0),
        2   : UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0),
        3   : UIColor(red: 0.99, green: 0.50, blue: 0, alpha: 1.0)
    ]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        convertToNSUrlAndGetJSONData()
        
    }

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    func convertToNSUrlAndGetJSONData(){
        
        
        /* actual url for routes */
        let urlString = "http://www.broncoshuttle.com/Region/0/Routes"
        
        if let url = NSURL(string: urlString){
            
            if let data = try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                            
                
                routesArray = routes.fromJSON(json)
     
//                retriveJSONData(json)
                
            } else{
                
                showAlertMessage("Service is not available")
                
            }
            tableView.reloadData()
        }
        
    }
    
    /**************************************************************************************
     getJSONData function will retrive the data (Routes Name) from the JSON using
     SwiftyJSON library. Routes name ("Name" : " Route A") gets stored into
     routesArray. numberOfRows = number of Routes are in the JSON file.
//     ***************************************************************************************/
//    func retriveJSONData(json: JSON){
//        
//        var routeName = String()
//        /* actual url for routes */
//        
//        for routes in json.arrayValue {
//            
//            routeName = routes["Name"].stringValue
//            
//            routesArray.append(routeName)
//            
//        }
//        
//    }

    /**************************************************************************************
     If tableView cell has not data to load, It will display AlerController message.
     ***************************************************************************************/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if routesArray.count == 0 {
            
            showAlertMessage("Service is not available")
        }
        
        return routesArray.count
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RouteCell")
        /********************************************************************
        Cell text color assigned to green and blue
        if index row = even no then the text color will be green else blue
        *********************************************************************/
        cell?.textLabel?.textColor = self.colors[indexPath.row]
        
        /********************************************************************
        Cell display the text from routesArray that contains data from Web.
        *********************************************************************/
        
        if routesArray.count != 0 {
            
            cell!.textLabel?.text  = routesArray[indexPath.row]

        }
        return cell!
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        route = routesArray[indexPath.row]
        
        let stopsViewController: StopsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RouteStopsSBID") as! StopsViewController
        
        stopsViewController.currentRoute  = route
        
    }
    
       /**************************************************************************************
     Selected cell's contect gets passed to StopsViewController as a currentRoute.
     ***************************************************************************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "routeStopsSegue"{
            
            let cell = sender as! UITableViewCell
            
            if let indexPath = tableView.indexPathForCell(cell){
                
                
                let controller = segue.destinationViewController as! StopsViewController
                
                controller.currentRoute = routesArray[indexPath.row]
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            }
        }
    }
    /**************************************************************************************
     Show Alert message.
     ***************************************************************************************/
    
    func showAlertMessage(errorMessage: String){
        
        let alertView = UIAlertController(title: "Message", message: errorMessage, preferredStyle: .Alert)
        let okResponse = UIAlertAction(title: "Ok", style: .Default, handler: nil)

        
        alertView.addAction(okResponse)
        presentViewController(alertView, animated: true, completion: nil)
        
        
        
    }
}