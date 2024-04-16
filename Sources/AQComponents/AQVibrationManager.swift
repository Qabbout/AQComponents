//
//  AQVibrationManager.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import UIKit

public final class AQVibrationManager: NSObject {
    
    public static let shared = AQVibrationManager()
    
    private override init() {
        super.init()
    }
    
    // Trigger a light impact feedback
    public func triggerImpactFeedback(of style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Trigger a selection feedback
    public func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // Trigger a notification feedback
    public func triggerNotificationFeedback(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

