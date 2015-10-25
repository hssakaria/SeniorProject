//
//  RoutesController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/21/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import UIKit
import SwiftyJSON

class RoutesController: UITableViewController, NSURLConnectionDelegate {
    
    var routesArray = [String]()
    var numberOfRows = 0
    //    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        parseJSON()
        
        
    }
    
    
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
    
    /***************************************************************************
    getJSONData function will retrive the data (Routes Name) from the JSON using 
    SwiftyJSON library. Routes name ("Name" : " Route A") gets stored into
    routesArray. numberOfRows = number of Routes are in the JSON file.
    ****************************************************************************/
    
    func getJSONData(json: JSON){
        //         var objects = [[String: String]]()
        //        var objects = [String]()
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
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        //       let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: <#T##NSIndexPath#>) as UITableViewCell!
        
        if routesArray.count != 0 {
            
            cell!.textLabel?.text  = routesArray[indexPath.row]
        }
        return cell!
        
    }

    
    
    
    
}