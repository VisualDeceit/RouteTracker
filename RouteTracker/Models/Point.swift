//
//  Track.swift
//  RouteTracker
//
//  Created by Александр Фомин on 09.11.2021.
//

import Foundation
import RealmSwift

class Point: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
}
