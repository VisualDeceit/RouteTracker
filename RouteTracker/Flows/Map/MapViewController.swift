//
//  MapViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 07.11.2021.
//

import UIKit
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var marker: GMSMarker?
    var isTracking: Bool = false
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startNewTrackButton: UIBarButtonItem!
    @IBOutlet weak var endTrackButton: UIBarButtonItem!
    @IBOutlet weak var showPreviousRouteButton: UIBarButtonItem!
    
    @IBAction func startNewTrackButtonTapped(_ sender: UIBarButtonItem) {
        toggleButtons()
        isTracking = true
        
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringSignificantLocationChanges()

        let zoomCamera = GMSCameraUpdate.zoom(to: 17)
        mapView.animate(with: zoomCamera)
    }
    
    @IBAction func endTrackButtonTapped(_ sender: UIBarButtonItem?) {
        toggleButtons()
        isTracking = false
        
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringSignificantLocationChanges()
        saveToDB(path: routePath)
    }
    
    @IBAction func showPreviousRouteButtonTapped(_ sender: UIBarButtonItem?) {
        guard !isTracking else {
            let alert = UIAlertController(title: "Ошибка", message: "Маршрут не завершен", preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Ok", style: .cancel)
            let actionFinish = UIAlertAction(title: "Завершить", style: .default) { [weak self] _ in
                self?.endTrackButtonTapped(nil)
                self?.showPreviousRouteButtonTapped(nil)
            }
            alert.addAction(actionCancel)
            alert.addAction(actionFinish)
            present(alert, animated: true)
            return
        }
        
        guard let routePath = loadFromDB()
        else {
            let alert = UIAlertController(title: "Ошибка", message: "Нет сохраненного маршрута", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(action)
            present(alert, animated: true)
            return
        }
        
        route?.map = nil
        route = GMSPolyline()
        route?.map = mapView
        route?.path = routePath
        let bounds = GMSCoordinateBounds(path: routePath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 10.0)
        mapView.moveCamera(update)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        configureMap()
    }
    
    private func toggleButtons() {
        startNewTrackButton.isEnabled.toggle()
        endTrackButton.isEnabled.toggle()
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 0.01, longitude: 0.01, zoom: 17.0)
        mapView.camera = camera
        
        marker = GMSMarker()
        let pinView = UIImageView(image: UIImage(systemName: "mappin"))
        pinView.tintColor = .red
        marker?.iconView = pinView
        marker?.map = mapView
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.requestAlwaysAuthorization()
    }
}

// MARK:- CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation =  locations.last,
              abs(newLocation.timestamp.timeIntervalSinceNow) < 5,
              newLocation.horizontalAccuracy > 0
        else { return }
        
        marker?.position = newLocation.coordinate
        routePath?.add(newLocation.coordinate)
        route?.path = routePath
        mapView.animate (toLocation: newLocation.coordinate)
        
        print(newLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorizedWhenInUse {
            startNewTrackButton.isEnabled = true
            // request current location first time
            locationManager?.requestLocation()
        }
    }
}

// MARK: - Realm

extension MapViewController {
    
    func convertToPoints(from path: GMSMutablePath) -> [Point] {
        var result = [Point]()
        for i in 0..<path.count() {
            let point = Point()
            point.latitude = path.coordinate(at: i).latitude
            point.longitude = path.coordinate(at: i).longitude
            result.append(point)
        }
        return result
    }
    
    func convertToPath(from points: [Point]) -> GMSMutablePath {
        let result = GMSMutablePath()
        points.forEach {
            result.add(CLLocationCoordinate2D(latitude: $0.latitude,
                                              longitude: $0.longitude))
        }
        return result
    }
    
    func saveToDB(path: GMSMutablePath?) {
        guard let path = path else { return }
        
        do {
            let realm = try Realm()
            print(String(describing: realm.configuration.fileURL))
            try realm.write {
                realm.deleteAll()
                
                let points = convertToPoints(from: path)
                realm.add(points)
            }
        } catch {
            print(error)
        }
    }
    
    func loadFromDB() -> GMSMutablePath? {
        do {
            let realm = try Realm()
            let points = Array(realm.objects(Point.self))
            if points.count == 0  { return nil }
            let path = convertToPath(from: points)
            return path
        } catch {
            print(error)
            return nil
        }
    }
}

