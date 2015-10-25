//
//  StopsTableViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/20/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import Foundation
import UIKit


class StopsTableViewController: UITableViewController{
    
    
    @IBOutlet weak var RouteTitle: UINavigationItem!
    
    var NewRouteTitle = String()
    
    override func viewDidLoad() {
        
        
        RouteTitle.title = NewRouteTitle;
        
    }
    
    
    
    
}

