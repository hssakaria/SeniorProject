//
//  DataManager.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/20/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import Foundation
import SpriteKit

class DataManager{
    
    let url = "http://www.apple.com/itunes/download/"
 
   
}

//
//
//class DataManger: SKScene {
//    
//    var bytes: NSMutableData?
//    
//    override func didMoveToView(view: SKView) {
//        
//        let requestURL = NSURLRequest(URL: NSURL(string: "http://www.apple.com/itunes/download/")!)
//        
//        let loader = NSURLConnection(request: requestURL, delegate: self, startImmediately: true)
//        
//    }
//    
//    
//    func connection(connection: NSURLConnection!, didReceiveData conData: NSData!){
//        self.bytes = NSMutableData()
//    }
//    
//    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
//        
//        self.bytes = NSMutableData()
//        
//    }
//    
//
//    func connectionDidFinsihLoading(connection: NSURLConnection!){
//        
////        do{
////            let jsonResult: Dictionary = NSJSONSerialization.JSONObjectWithData(self.bytes, options: NSJSONReadingOptions.MutableContainers, error: nil) as Dictionary<String, AnyObject>
////            
//            do {
//                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(self.bytes!, options: []) as? NSDictionary {
//                    print(jsonResult)
//                }
//            } catch {
//                print(error)
//            }
////        let results: NSArray = jsonResult["Routes"]! as NSArray
////        for item in results {
////            
////            // we convert each key to a String
////            
////            var name: String = item["Name"] as String
////            
////            
////            print("\(name): ")
////        }
//        
//        
//        
////    }
//    
//    
//}
//override func update(currentTime: CFTimeInterval){
//    
//}
//
////
////    class func getTopAppsDataFromItunesWithSuccess(success: ((iTunesData: NSData!) -> Void)) {
////
////        loadDataFromURL(NSURL(string: TopAppURL)!, completion:{(data, error) -> Void in
////
////            if let urlData = data {
////                //3
////                success(iTunesData: urlData)
////            }
////        })
////    }
//}