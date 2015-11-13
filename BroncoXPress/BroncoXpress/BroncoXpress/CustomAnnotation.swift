//
//  CustomAnnotation.swift
//  BroncoXpress
//
//  Created by Hetal Sakaria on 11/13/15.
//  Copyright © 2015 Hetal Sakaria. All rights reserved.
//

import MapKit
import UIKit

class CustomAnnotation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
    }
}
