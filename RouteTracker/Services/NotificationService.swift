//
//  NotificationService.swift
//  RouteTracker
//
//  Created by Александр Фомин on 23.11.2021.
//

import Foundation
import NotificationCenter

final class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    private init() {}
    
    func registerForNotifications() {
        center.getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization { granted in
                    guard granted else { return }
                    print("Request Authorization success")
                }
            case .denied:
                print("Application Not Allowed to Display Notifications")
            default:
                break
            }
        }
    }
    
    func sendNotification(identifier: String,
                          time: Date,
                          title: String,
                          body: String,
                          isNeedRepeat: Bool = false,
                          completion: ((Error?) -> Void)? = nil) {
        let trigger = makeTrigger(time: time, isNeedRepeat: isNeedRepeat)
        let content = makeNotification(title: title, body: body)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: completion)
    }
    
    func removeAllNotification() {
        center.removeAllPendingNotificationRequests()
    }
    
    private func makeTrigger(time: Date, isNeedRepeat: Bool) -> UNCalendarNotificationTrigger {
        let componentsForTime = Calendar.current.dateComponents([.hour, .minute], from: time)

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = componentsForTime.hour
        dateComponents.minute = componentsForTime.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: isNeedRepeat)
        return trigger
    }
    
    private func makeNotification(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }
    
    private func requestAuthorization(completionHandler: @escaping (Bool) -> ()) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(granted)
        }
    }
}
