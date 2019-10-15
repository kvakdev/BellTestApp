//
//  LocationManager.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

public protocol LocationManagerProtocol {
    var currentLocation: BehaviorSubject<CLLocation> { get }
}

public class LocationManager: NSObject, LocationManagerProtocol {
    private let locationManager = CLLocationManager()

    static let shared = LocationManager()
    public var currentLocation: BehaviorSubject<CLLocation> = .init(value: CLLocation())

    override private init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        requestAuthorizationIfNeeded()
    }
    
    private func requestAuthorizationIfNeeded() {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined || status == .denied {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        currentLocation.onNext(last)
    }
}
