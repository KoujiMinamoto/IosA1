//
//  Sight+CoreDataProperties.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//
//

import Foundation
import CoreData


extension Sight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sight> {
        return NSFetchRequest<Sight>(entityName: "Sight")
    }

    @NSManaged public var name: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var icon: String?
    @NSManaged public var image: String?

}
