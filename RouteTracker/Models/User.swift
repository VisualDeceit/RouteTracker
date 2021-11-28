//
//  User.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var login: String
    @Persisted var password: String
    @Persisted var avatar: Data
    @Persisted var route: List<Point>
}
