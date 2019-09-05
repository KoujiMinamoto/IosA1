//
//  LocationAnnotation.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    
    init(newTitle: String, newSubtitle: String, lat: Double, long: Double) {
        self.title = newTitle
        self.subtitle = newSubtitle
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
}
