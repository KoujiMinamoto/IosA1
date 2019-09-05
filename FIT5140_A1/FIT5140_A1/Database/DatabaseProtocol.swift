//
//  DatabaseProtocol.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

protocol DatabaseListener: AnyObject {
    func onSightsChange(change: DatabaseChange, sights: [Sight])
}

protocol DatabaseProtocol: AnyObject {
    func addSight(name: String, descriptions: String, latitude: Double, longitude: Double, icon: String, image: String) -> Sight
    func deleteSight(sight: Sight)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
