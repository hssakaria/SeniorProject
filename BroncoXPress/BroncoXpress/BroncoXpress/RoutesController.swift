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
    var numberOfRows = 0
    
    var route = String()
    
   
    let colors = [
        0   : UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0),
        1   : UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0),
        2   : UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0),
        3   : UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    ]
    override func viewDidLoad() {
        
        super.viewDidLoad()

        parseJSON()
        
    }
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackOpaque
        
//        nav?.titleTextAttributes = [NSForegroundColorAttributeName: self.colors[2]!]
        nav?.tintColor = UIColor.whiteColor()
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    func parseJSON(){
        
        
        /* actual url for routes */
        
        let urlString = "http://www.broncoshuttle.com/Region/0/Routes"
        
        if let url = NSURL(string: urlString){
            
            if let data = try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                getJSONData(json)
                
            } else{
                showError()
            }
            tableView.reloadData()
        }
        
    }
    /**************************************************************************************
     getJSONData function will retrive the data (Routes Name) from the JSON using
     SwiftyJSON library. Routes name ("Name" : " Route A") gets stored into
     routesArray. numberOfRows = number of Routes are in the JSON file.
     ***************************************************************************************/
    func getJSONData(json: JSON){
        
        var routeName = String()
        /* actual url for routes */
        
        for routes in json.arrayValue {
            
            routeName = routes["Name"].stringValue

            routesArray.append(routeName)
            numberOfRows = routesArray.count // count how many routes are in the JSON file.
            
        }

    }
    
    func showError(){
        
        print("Could not load data")
        
        
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    /**************************************************************************************
     
     ***************************************************************************************/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RouteCell")
        
//        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "RouteCell")
        
        
     print("idex  \([indexPath.row])")
        
        
        /********************************************************************
        Cell text color assigned to green and blue
        if index row = even no then the text color will be green else blue
        *********************************************************************/
            cell?.textLabel?.textColor = self.colors[indexPath.row]
     
        /********************************************************************
        Cell display the text from routesArray that contains data from Web.
        *********************************************************************/
        //       let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: <#T##NSIndexPath#>) as UITableViewCell!
        
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
    
    
}