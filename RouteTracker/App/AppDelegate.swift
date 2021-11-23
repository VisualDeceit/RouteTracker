//
//  AppDelegate.swift
//  RouteTracker
//
//  Created by Александр Фомин on 07.11.2021.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyB2wnjFrZFo-30jow3rPhBQG27NftreMoU")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationService.shared.registerForNotifications()
        
        return true
    }
    
    @objc func applicationDidBecomeBackground() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.tag = -1;
        
        if let rootView =  UIApplication.shared.windows.first {
            rootView.addSubview(blurView)
            
            blurView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: rootView.topAnchor),
                blurView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
                blurView.heightAnchor.constraint(equalTo: rootView.heightAnchor),
                blurView.widthAnchor.constraint(equalTo: rootView.widthAnchor)
            ])
        }
        NotificationService.shared.sendNotification(identifier: "reminder_30_min",
                                                    time: Date(timeIntervalSinceNow: 60.0 * 1.0),
                                                    title: "Прошло уже 30 минут",
                                                    body: "У вас есть незавершенный маршрут")
    }
    
    @objc func applicationDidBecomeActive() {
        if let rootView =  UIApplication.shared.windows.first,
           let blurView = rootView.viewWithTag(-1){
            blurView.removeFromSuperview()
        }
        NotificationService.shared.removeAllNotification()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

