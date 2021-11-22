//
//  MapViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 07.11.2021.
//

import UIKit
import GoogleMaps
import RealmSwift
import RxCocoa

class MapViewController: UIViewController {
    
    let locationManager = LocationManager.shared
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var marker: GMSMarker?
    var isTracking: Bool = false
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recordTrackButton: UIButton!
    @IBOutlet weak var showRouteButton: UIBarButtonItem!
    
    @IBAction func recordTrackButtonTapped(_ sender: UIButton?) {
        if !isTracking {
            route?.map = nil
            route = GMSPolyline()
            routePath = GMSMutablePath()
            route?.map = mapView
            
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()

            let zoomCamera = GMSCameraUpdate.zoom(to: 17)
            mapView.animate(with: zoomCamera)
            
            isTracking.toggle()
            sender?.setImage( UIImage(systemName: "stop.circle"), for: .normal)
            sender?.tintColor = .black
        } else {
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringSignificantLocationChanges()
            saveToDB(path: routePath)
            
            isTracking.toggle()
            sender?.setImage( UIImage(systemName: "record.circle"), for: .normal)
            sender?.tintColor = .red
        }
    }

    @IBAction func showRouteButtonTapped(_ sender: UIBarButtonItem?) {
        guard !isTracking else {
            let alert = UIAlertController(title: "Ошибка", message: "Маршрут не завершен", preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Ok", style: .cancel)
            let actionFinish = UIAlertAction(title: "Завершить", style: .default) { [weak self] _ in
                self?.recordTrackButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
                self?.recordTrackButton.tintColor = .red
                self?.recordTrackButtonTapped(nil)
                self?.showRouteButtonTapped(nil)
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

    func configureMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 0.01, longitude: 0.01, zoom: 17.0)
        mapView.camera = camera
        
        marker = GMSMarker()
        let pinView = UIImageView(image: UIImage(systemName: "mappin"))
        pinView.tintColor = .red
        marker?.iconView = pinView
        marker?.map = mapView
        mapView.addSubview(recordTrackButton)
    }
    
    func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                self?.route?.path = self?.routePath
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
                
                self?.marker?.position = location.coordinate
            }.dispose()
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
            try realm.write {
                let oldPoints = realm.objects(Point.self)
                realm.delete(oldPoints)
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

