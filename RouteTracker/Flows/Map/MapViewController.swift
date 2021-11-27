//
//  MapViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 07.11.2021.
//

import UIKit
import GoogleMaps
import RealmSwift
import RxSwift
import RxCocoa

final class MapViewController: UIViewController {
    let locationManager = LocationManager.shared
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var marker: GMSMarker?
    var isTracking: Bool = false
    var avatarImage: UIImage!
    
    private let bag = DisposeBag()
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        saveToDB(path: routePath)
    }

    func configureMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 0.01, longitude: 0.01, zoom: 17.0)
        mapView.camera = camera
        
        marker = GMSMarker()
        let pinView = UIImageView(image: avatarImage)
        pinView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        pinView.layer.cornerRadius = 16
        pinView.layer.masksToBounds = true
        pinView.tintColor = .red
        marker?.iconView = pinView
        marker?.map = mapView
        mapView.addSubview(recordTrackButton)
    }
    
    func configureLocationManager() {
        locationManager
            .location
            .subscribe { [weak self] (event) in
                switch event {
                case .next(let location):
                    guard let location = location else { return }
                    
                    self?.routePath?.add(location.coordinate)
                    self?.route?.path = self?.routePath
                    self?.marker?.position = location.coordinate
                    self?.mapView.animate(toLocation: location.coordinate)
                case .error(let error):
                    print(error.localizedDescription)
                case .completed:
                    print("completed")
                }
            }.disposed(by: bag)
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

