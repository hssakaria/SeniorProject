//
//  ViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/16/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    
   
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var broncoXpressLabel: UILabel!
    @IBOutlet weak var LiveMapBtn: UIButton!
    
    @IBOutlet weak var RoutesBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        LiveMapBtn.layer.borderWidth = 3
         LiveMapBtn.layer.borderColor = UIColor(red: 0.21, green: 0.80, blue: 0.02, alpha: 1.0).CGColor
        
        
        RoutesBtn.layer.borderWidth = 3
        RoutesBtn.layer.borderColor = UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0).CGColor
   
        
        
        
//        /* Navigation Bar Style */
//        let nav = self.navigationController?.navigationBar
//        nav?.barStyle = UIBarStyle.BlackOpaque
//        
//        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.greenColor()]
//        nav?.tintColor = UIColor.whiteColor()
//   
        /* For Animated welcome bronco xpress */
        
//        welcomeLabel.center.x = self.view.frame.width + 30
//        
//        UIView.animateWithDuration(4.0, delay: 0, usingSpringWithDamping: 3.0, initialSpringVelocity: 20, options: [], animations: ({
//            
//            self.welcomeLabel.center.x = self.view.frame.width / 2
//       
//        }), completion: nil)
//        
//        broncoXpressLabel.center.x = self.view.frame.width + 30
//        
//        UIView.animateWithDuration(5.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 40, options: [], animations: ({
//            
//            self.broncoXpressLabel.center.x = self.view.frame.width / 2
//            
//        }), completion: nil)
//        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        /* Navigation Bar Style */
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackOpaque
        
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.tintColor = UIColor.whiteColor()
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

}
