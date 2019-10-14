//
//  MapModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

protocol PMapModel {
    var currentRadius: Int { get set }
    var tweets: PublishSubject<[Tweet]> { get }
    var location: PublishSubject<CLLocation> { get }
    var presentableError: PublishSubject<Error> { get }

    func start()
}

class MapModel: PMapModel {
    var tweets: PublishSubject<[Tweet]> = .init()
    var location: PublishSubject<CLLocation> = .init()
    var presentableError: PublishSubject<Error> = .init()
    
    private let locationManager: PLocationManager
    private let searchService: PTweetAPIService
    
    private var lastLocation: CLLocation?
    
    var currentRadius: Int = 5 {
        didSet {
            if let location = lastLocation {
                load(with: location, radius: self.currentRadius)
            }
        }
    }
    
    private let disposeBag = DisposeBag()
    
    init(locationManager: PLocationManager, searchService: PTweetAPIService) {
        self.locationManager = locationManager
        self.searchService = searchService
    }
    
    func start() {
        locationManager.currentLocation.subscribe(onNext: { [weak self] location in
            guard let self = self else { return }
            self.lastLocation = location
            self.location.onNext(location)
            self.load(with: location, radius: self.currentRadius)
            
        }).disposed(by: disposeBag)
    }
    
    private func load(with location: CLLocation, radius: Int) {
        let query = RadiusQuery(radius: radius, location: location, count: 1000, filter: { tweet in
             return tweet.place != nil
        })
        
        self.searchService.searchTweets(query: query) { [weak self] result in
            switch result {
            case .success(let tweets):
                print("got \(tweets.count) filteredTweets")
                self?.tweets.onNext(tweets)
            case .failure(let error):
                if let error = error {
                    self?.presentableError.onNext(error)
                }
            }
        }
    }
}
