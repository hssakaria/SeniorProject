//
//  RetriveLatitudeLongitudeFromJSON.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 11/15/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import Foundation
import SwiftyJSON

class RetriveCoordinatesFromJSON {
     
    func fromJSONToPoints(json: JSON, Latitude: String) -> [Double] {
        
        var coordinate: Double = 0.0
        
        var coordinatesArray: [Double] = []
        
        for jsonData in json.arrayValue {
            
            if jsonData.count != 0 {
                coordinate = jsonData[Latitude].doubleValue
                
                coordinatesArray.append(coordinate)
            }
            else{
                print("Data is unavailable!")
            }
        }
        return coordinatesArray

        
    }

    
    func fromJSONToPolyLine(json: JSON, Latitude: String) -> [Double] {
        
        var coordinate: Double = 0.0
        
        var coordinatesArray: [Double] = []
        
        for jsonData in json[0].arrayValue {
            
            coordinate = jsonData[Latitude].doubleValue
            
            coordinatesArray.append(coordinate)
        }
        return coordinatesArray
        
        
    }
    

}