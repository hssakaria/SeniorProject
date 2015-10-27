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
//
//class StopsViewController
//: UITableViewController{
//

class StopsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var stopsTableView: UITableView!
    
    
    @IBOutlet var RouteName: UILabel!
    var currentRoute: String?
    
    var busStopsArray = [String]()
    var numberOfRows2 = 0
    var stopName = String()
    
    var colorGreen = UIColor(red: 0.1333, green: 0.4275, blue: 0, alpha: 1.0)
    var colorBlue = UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0)
    var colorRed = UIColor(red: 1, green: 0.0314, blue: 0, alpha: 1.0)
    var colorPurple = UIColor(red: 0.9725, green: 0, blue: 0.9882, alpha: 1.0)
    
    
    override func viewDidLoad() {
        
        
        self.RouteName.text = currentRoute
        
        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        
        
        print(currentRoute)
        
        parseJSON()
        
    }
    
    
    
    
    func parseJSON(){
        
        let urlRouteB1 = "http://www.broncoshuttle.com/Route/3166/Direction/0/Stops"
        
        if let url = NSURL(string: urlRouteB1){
            
            if let data =  try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                getJSONData(json)
            }
            else{
                
                NSLog("Couldnt load Bus Stops data")
                // show error
            }
            
            
             self.stopsTableView.reloadData()
        }
        
    }
    
    /**************************************************************************************
    
    ***************************************************************************************/
    
    
    func getJSONData(json: JSON){
        
        var busStopsName = String()
        
        
        for busStops in json.arrayValue {
            
            busStopsName = busStops["Name"].stringValue
            busStopsArray.append(busStopsName)
            numberOfRows2 = busStopsArray.count
        }
        
        print(busStopsArray)
        
    }
    
    /**************************************************************************************
    
    ***************************************************************************************/
    
    func tableView(stopsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("numberOfRows2")
        
        
        return numberOfRows2
    }
    
    /**************************************************************************************
    
    ***************************************************************************************/
    
    func tableView(stopsTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = stopsTableView.dequeueReusableCellWithIdentifier("BusStopsCell")
        
        /********************************************************************
        Cell text color assigned to green and blue
        if index row = even no then the text color will be green else blue
        *********************************************************************/
        if indexPath.row % 2 == 0 {
            cell!.textLabel?.textColor = colorGreen
        }
        else if indexPath.row % 3 == 0{
            cell?.textLabel?.textColor = colorPurple

        }
        else{
            cell!.textLabel?.textColor = colorBlue
        }
        
        
        /********************************************************************
        Cell display the text from routesArray that contains data from Web.
        *********************************************************************/
        
        if busStopsArray.count != 0 {
            
            cell!.textLabel?.text  = busStopsArray[indexPath.row]
        }
        return cell!        
    }
    
    
    /**************************************************************************************
    On touch, it will dismiss the currentViewController and go back to RoutesViewController
    ***************************************************************************************/
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

