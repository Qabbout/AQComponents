//
//  AQNotificationManager.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit
import UserNotifications

public final class AQNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    public static let shared = AQNotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
    }
    
    public func requestAuthorization(options: UNAuthorizationOptions) async -> Result<Bool, Error> {
        do {
            let result = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            return .success(result)
        } catch {
            dump("Authorization failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    private func registerNotificationCategories() {
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION",
                                                title: "Snooze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let markAsDoneAction = UNNotificationAction(identifier: "MARK_AS_DONE_ACTION",
                                                    title: "Mark as Done",
                                                    options: .foreground)
        
        let category = UNNotificationCategory(identifier: "TASK_CATEGORY",
                                              actions: [snoozeAction, markAsDoneAction],
                                              intentIdentifiers: [],
                                              options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    public func scheduleNotification(identifier: String = UUID().uuidString, title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "TASK_CATEGORY"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                dump("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    public func updateScheduledNotification(identifier: String, title: String, body: String, timeInterval: TimeInterval) {
        removeNotifications(identifiers: [identifier])
        scheduleNotification(identifier: identifier, title: title, body: body, timeInterval: timeInterval)
    }
    
    public func removeNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if #available(iOS 14.0, *) {
            return [.banner, .badge, .sound, .list]
        } else {
            return [.badge, .sound]
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let identifier = response.notification.request.identifier
        dump("Handled notification with ID: \(identifier)")
    }
    
    
    //    public func requestAuthorization(options: UNAuthorizationOptions, completion: @escaping (Bool) -> Void) {
    //        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
    //            if let error = error {
    //                dump("Authorization failed: \(error.localizedDescription)")
    //                completion(false)
    //            } else {
    //                completion(granted)
    //            }
    //        }
    //    }
    
    //    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //        if #available(iOS 14.0, *) {
    //            completionHandler([.banner, .badge, .sound, .list])
    //        } else {
    //            completionHandler([.badge, .sound])
    //        }
    //    }
    
    //    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //        let identifier = response.notification.request.identifier
    //        dump("Handled notification with ID: \(identifier)")
    //        completionHandler()
    //    }
}
