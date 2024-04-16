//
//  AQCalendarManager.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit
import EventKit

public final class AQCalendarManager: NSObject {
    
    public static let shared = AQCalendarManager()
    private override init() {
        super.init()
    }
    
    // MARK: - Add event to calendar
    public func addEventToCalendar(title: String,
                                   description: String?,
                                   startDate: Date?,
                                   endDate: Date?,
                                   location: String?,
                                   alarmBeforeEventInMinutes: Double? = nil,
                                   completion: ((_ success: Bool, _ error: String?) -> Void)? = nil) {
        
        DispatchQueue.global(qos: .background).async { () -> Void in
            
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    
                    // Prepare the event alarm
                    var alarm = EKAlarm()
                    if let alarmBeforeEventInMinutes = alarmBeforeEventInMinutes {
                        let aInterval: TimeInterval = -(alarmBeforeEventInMinutes) * 60
                        alarm = EKAlarm(relativeOffset: aInterval)
                    }
                    
                    // Prepare the event
                    let customEventTitle = "Event - \(title)"
                    let event = EKEvent(eventStore: eventStore)
                    event.title = customEventTitle
                    event.startDate = startDate
                    event.endDate = endDate
                    event.notes = description
                    event.alarms = [alarm]
                    event.location = location
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    // Check if its already exists!
                    let exist = self.isEventExists(newEventTitle: customEventTitle, newEventStartDate: startDate, newEventEndDate: endDate)
                    if exist == false {
                        
                        // Ok to save
                        do {
                            try eventStore.save(event, span: .thisEvent)
                            completion?(true, nil)
                        } catch let e as NSError {
                            completion?(false, e.localizedDescription)
                        }
                        
                    } else {
                        // Nope, its already saved!!
                        completion?(false, "Event already exists!")
                    }
                } else {
                    if granted == false && error == nil {
                        completion?(false, "Please go to settings and allow this app to access your calendar")
                    } else {
                        completion?(false, error?.localizedDescription)
                    }
                }
            })
        }
    }
    
    // MARK: - Check if event already exists
    private func isEventExists(newEventTitle: String, newEventStartDate: Date?, newEventEndDate: Date?) -> Bool {
        
        var exist = false
        if let newEventStartDate = newEventStartDate, let newEventEndDate = newEventEndDate {
            let predicate = EKEventStore().predicateForEvents(withStart: newEventStartDate, end: newEventEndDate, calendars: nil)
            let existingEvents = EKEventStore().events(matching: predicate)
            var titles = [String]()
            for event in existingEvents {
                let existingEventTitle = event.title ?? ""
                titles.append(existingEventTitle)
            }
            for singleTitle in titles {
                if singleTitle.cleanupString().lowercased() == newEventTitle.cleanupString().lowercased() {
                    exist = true
                    break
                }
            }
        }
        return exist
    }
}
