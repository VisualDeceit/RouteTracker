//
//  Track.swift
//  RouteTracker
//
//  Created by Александр Фомин on 09.11.2021.
//

import Foundation
import RealmSwift

class Point: Object {
    @Persisted var latitude: Double
    @Persisted var longitude: Double
}
