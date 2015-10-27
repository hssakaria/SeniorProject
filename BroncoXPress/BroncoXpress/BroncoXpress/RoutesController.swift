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
    
    var colorGreen = UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0)
    var colorBlue = UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0)
    var colorRed = UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    var colorPurple = UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0)
    
    //    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        parseJSON()
        
        
    }
    
    /**************************************************************************************
    
    ***************************************************************************************/
    
    func parseJSON(){
        
        
        /* actual url for routes */
        
        let urlString = "http://www.broncoshuttle.com/Region/0/Routes"
        
        if let url = NSURL(string: urlString){
            
            if let data = try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                //                        print(json.arrayValue) // display json file
                getJSONData(json)
                //                tableView.reloadData()
                
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
        //         var objects = [[String: String]]()
        //        var objects = [String]()
        //        var routeName = String()
        
        var routeName = String()
        /* actual url for routes */
        
        for routes in json.arrayValue {
            
            routeName = routes["Name"].stringValue
            //           let obj = [routeName]
            //            objects.append(routeName)
            routesArray.append(routeName)
            numberOfRows = routesArray.count // count how many routes are in the JSON file.
            
        }
        
        print(routesArray)
        
        
        //
        /* online */
        //
        //            for result in json["results"].arrayValue {
        //                let title = result["title"].stringValue
        //                let body = result["body"].stringValue
        //                let sigs = result["signatureCount"].stringValue
        //                let obj = ["title": title, "body": body, "sigs": sigs]
        //                objects.append(obj)
        //            }
        
        //        print(objects)
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        
        /********************************************************************
        Cell text color assigned to green and blue
        if index row = even no then the text color will be green else blue
        *********************************************************************/
        if indexPath.row % 2 == 0 {
            cell?.textLabel?.textColor = colorGreen
        }
        else if indexPath.row % 3 == 0{
            cell?.textLabel?.textColor = colorPurple
            
        }
        else if indexPath.row % 5 == 0{
            cell?.textLabel?.textColor = colorRed
            
        }
        else{
            cell?.textLabel?.textColor = colorBlue
        }
        
        
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
        
        
        let stopsViewController: StopsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RouteStops") as! StopsViewController
        self.presentViewController(stopsViewController, animated: true, completion: nil)
        
        // self.navigationController?.pushViewController(stopsViewController, animated: true)
        
        stopsViewController.currentRoute = route
        
    }
    
    /**************************************************************************************
    Selected cell's contect gets passed to StopsViewController as a currentRoute.
    ***************************************************************************************/
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "routeStopSegue"{
    //
    //            let controller = segue.destinationViewController as! StopsViewController
    //            controller.currentRoute = route
    //
    //        }
    //    }
    
    
}