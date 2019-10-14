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

class MapModel: PMapModel {
    var tweets: PublishSubject<[Tweet]> = .init()
    var location: PublishSubject<CLLocation> = .init()
    var presentableError: PublishSubject<Error> = .init()
    var accumulatableTweets: PublishSubject<[Tweet]> = .init()
    
    private let locationManager: PLocationManager
    private let searchService: PTweetAPIService
    
    private var lastLocation: CLLocation?
    private let disposeBag = DisposeBag()
    
    var currentRadius: Int = 5 {
        didSet {
            if let location = lastLocation {
                load(with: location, radius: self.currentRadius)
            }
        }
    }
    
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
    
    func fetchAfter(id: String) {
        guard let location = lastLocation else { return }
        let query = RadiusQuery(radius: currentRadius, location: location, count: 100, sinceId: id, filter: { tweet in
             return tweet.place != nil
        })
        
        self.searchService.searchTweets(query: query) { [weak self] result in
            switch result {
            case .success(let tweets):
//                debugPrint("Timer got \(tweets.count) filteredTweets")
                self?.accumulatableTweets.onNext(tweets)
            case .failure(let error):
                if let error = error {
                    self?.presentableError.onNext(error)
                }
            }
        }
    }
    // MARK: Private methods
    private func load(with location: CLLocation, radius: Int) {
        let query = RadiusQuery(radius: radius, location: location, count: 1000, sinceId: nil, filter: { tweet in
             return tweet.place != nil
        })
        
        self.searchService.searchTweets(query: query) { [weak self] result in
            switch result {
            case .success(let tweets):
//                debugPrint("got \(tweets.count) filteredTweets")
                self?.tweets.onNext(tweets)
            case .failure(let error):
                if let error = error {
                    self?.presentableError.onNext(error)
                }
            }
        }
    }
}
