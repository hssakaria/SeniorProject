//
//  CPPAnnotation.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 11/13/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import UIKit
import MapKit


class CPPAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
}