//
//  ViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/16/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    
   
    @IBOutlet weak var LiveMapBtn: UIButton!
    
    @IBOutlet weak var RoutesBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        LiveMapBtn.layer.borderWidth = 3
//        LiveMapBtn.layer.borderColor = UIColor.blueColor().CGColor
         LiveMapBtn.layer.borderColor = UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0).CGColor
        
        
        RoutesBtn.layer.borderWidth = 3
        RoutesBtn.layer.borderColor = UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0).CGColor
   
        
   
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func RoutesBtn(sender: AnyObject) {
//    let query = PFQuery(className: "Routes")
//        query.w
//        query.findObjectsInBackgroundWithBlock{(objects, error) -> Void in
//            if error == nil{
//                print("Successfully retrived: \(objects)")
//            }
//            else{
//                print("Error: \(error) \(error.userInfo!)")
//
//            }
//        
//        }
        
    }
}
