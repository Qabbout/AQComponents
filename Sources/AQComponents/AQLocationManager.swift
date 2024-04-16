//
//  AQLocationManager.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//


import UIKit
import CoreLocation

/// (_ alwaysAuthorization:Bool, _ whenInUseAuthorization:Bool)
public typealias AQLocationManagerCompletion = (_ authorizationStatus: CLAuthorizationStatus) -> Void
public typealias AQLocationUpdateCompletion = (_ result: AQLocationManager.AQLocationUpdatesResult) -> Void

public extension AQLocationManager {
    
    struct AQLocationUpdatesResult {
        public let error: Error?
        public let location: CLLocationCoordinate2D?
    }
    
    enum AQLocationRequestType {
        case always
        case whenInUse
        case oneTime
    }
}

public final class AQLocationManager: NSObject {
    
    // MARK: - Private properties
    private var locationManager: CLLocationManager?
    private var locationUpdateTimer: Timer?
    private var completion: AQLocationManagerCompletion?
    private var locationUpdateCompletion: AQLocationUpdateCompletion?
    
    // MARK: - Shared
    public static let shared = AQLocationManager()
    private override init() {
        super.init()
    }
    
    // MARK: - Ask for location
    /// Ask for location access
    /// - Parameter completion: (_ alwaysAuthorization:Bool, _ whenInUseAuthorization:Bool)
    public func askForLocation(requestType: AQLocationRequestType,completion: @escaping AQLocationManagerCompletion) {
        self.clearValues()
        self.completion = completion
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
        switch requestType {
        case .always:
            locationManager?.requestAlwaysAuthorization()
        case .whenInUse:
            locationManager?.requestWhenInUseAuthorization()
        case .oneTime:
            locationManager?.requestLocation()
        }
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.allowsBackgroundLocationUpdates = false
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    // MARK: - Observe Location Update
    public func observeLocationUpdate(completion:@escaping AQLocationUpdateCompletion) {
        self.locationUpdateCompletion = completion
    }
    
    // MARK: - Clear Values
    public func clearValues() {
        self.locationManager = nil
        self.locationUpdateCompletion = nil
        self.completion = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension AQLocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Send completion feedback
        if let location = manager.location?.coordinate {
            manager.stopUpdatingLocation()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
                guard let self = self else { return }
                self.locationUpdateTimer?.invalidate()
                self.locationUpdateTimer = .scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                    timer.invalidate()
                    self.locationUpdateCompletion?(.init(error: nil, location: location))
                })
            })
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.completion?(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationUpdateCompletion?(.init(error: error, location: nil))
    }
}

