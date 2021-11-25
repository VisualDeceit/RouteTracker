//
//  CoreLocation.swift
//  RouteTracker
//
//  Created by Александр Фомин on 21.11.2021.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationService: NSObject{
    static var shared = LocationService()
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    let locationManager = CLLocationManager()
    
    let location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil) //= Variable(nil)

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation =  locations.last,
              abs(newLocation.timestamp.timeIntervalSinceNow) < 5,
              newLocation.horizontalAccuracy > 0
        else { return }
        location.accept(newLocation)
        
//        marker?.position = newLocation.coordinate
//        routePath?.add(newLocation.coordinate)
//        route?.path = routePath
//        mapView.animate (toLocation: newLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        if manager.authorizationStatus == .authorizedAlways ||
//            manager.authorizationStatus == .authorizedWhenInUse {
//            recordTrackButton.isEnabled = true
//            // request current location first time
//            locationManager?.requestLocation()
//        }
    }
}
