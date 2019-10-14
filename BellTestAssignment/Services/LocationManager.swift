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

protocol PLocationManager {
    var currentLocation: PublishSubject<CLLocation> { get }
}

class LocationManager: NSObject, PLocationManager {
    static let shared = LocationManager()
    
    var currentLocation: PublishSubject<CLLocation> = .init()
    
    private let locationManager = CLLocationManager()
    private var _currentLocation: CLLocation?
    
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
    
    private func set(_ location: CLLocation) {
        _currentLocation = location
      
        currentLocation.onNext(location)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let last = locations.last else { return }
        
        set(last)
    }
}