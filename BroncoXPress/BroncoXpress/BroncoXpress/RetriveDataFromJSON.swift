//
//  RetriveDataJSON.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 11/15/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RetriveDataFromJSON: NSObject{


    func fromJSON(json: JSON) -> [String] {
        
        
        var name: String
        var nameArray = [String]()
    
        
        for jsonData in json.arrayValue {
            
        
            
            name = jsonData["Name"].stringValue
            
            nameArray.append(name)
            
        }
        return nameArray
        
    }
    
    
    func fromJSONgetHeading(json: JSON) -> [String] {
        
        
        var heading: String
        var headingArray = [String]()
        
        
        for jsonData in json.arrayValue {
            
            
            
            heading = jsonData["Heading"].stringValue
            
            headingArray.append(heading)
            
        }
        return headingArray
        
    }
}