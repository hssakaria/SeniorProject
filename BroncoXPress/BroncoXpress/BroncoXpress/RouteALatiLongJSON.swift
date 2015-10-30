//
//  RouteALatiLongJSON.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/29/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RouteALatiLongJSON: NSObject {
    
    
    let urlString = "http://www.broncoshuttle.com/Route/3164/Waypoints/"
    var beaconUUID = CLBeaconRegion()
    var min: Int = 0
    var routeLatiLongArray = [Int]()
    
    init(beaconUUID: CLBeaconRegion, min: Int) {
        self.beaconUUID = beaconUUID
        self.min = min
    }
    
    func parseJSON(){
        //
        if let url = NSURL(string: urlString) {
            
            if let data = try? NSData(contentsOfURL: url, options: []){
                
                let json = JSON(data: data)
                
                //                        print(json.arrayValue) // display json file
                getJSONData(json)
                
            } else{
                //            showError()
            }
        }
    }
    //
    //
    
    func getJSONData(json: JSON) ->  [Int]{
        //        var objects = [[String: String]]()
        var routeLatitude = Int()
        var routeLongitude = Int()
        
//        var routeName = String()
        /* actual url for routes */
        
        for routeslatilong in json.arrayValue {
    
            
        }
        return(routeLatiLongArray)
        
        print(routeLatiLongArray)
    }
    
    
}