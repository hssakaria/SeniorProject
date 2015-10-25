//
//  RoutesTableViewController.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 10/17/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import UIKit


class RoutesTableViewController: PFQueryTableViewController{
    
    var color = UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0)
    
    /***********************************************************************************
    @IBOutlet weak var RouteName: PFTableViewCell!
    Designated initializer init, which takes two parameters:the style of the table view,
    and the className from Parse we want to use (that’s Routes)
    ************************************************************************************/
    override init(style: UITableViewStyle, className: String!){
        super.init(style: style, className: className)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        self.parseClassName = "Routes"
        self.textKey="BusRoutes"
        
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        //        self.objectsPerPage = 10 (if you make paginationEables = true then uncomment this like)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Routes Table View Controller is loaded")
        
        self.navigationController?.navigationBar.tintColor = color
        
        
        
        
    }
        /***********************************************************************************
    The query parameteres Parse will use when connecting to the server data set.
    ************************************************************************************/
    
    override func queryForTable() -> PFQuery {
        let query: PFQuery = PFQuery(className: "Routes")
        
        query.orderByAscending("BusRoutes")
        return query
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //code
    }
	
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//CODE TO BE RUN ON CELL TOUCH
	}
	
}

