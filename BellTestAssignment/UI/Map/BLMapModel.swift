//
//  BLMapModel.swift
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
    var tweets: PublishSubject<[BLTweet]> { get }
    var location: PublishSubject<CLLocation> { get }

    func start()
}

class BLMapModel: PMapModel {
    var tweets: PublishSubject<[BLTweet]> = .init()
    var location: PublishSubject<CLLocation> = .init()
    
    private let _locationManager: PLocationManager
    private let _searchService: BLTweetSearchService
    private var _lastLocation: CLLocation?
    
    var currentRadius: Int = 5 {
        didSet {
            if let location = _lastLocation {
                load(with: location, radius: self.currentRadius)
            }
        }
    }
    
    private let _disposeBag = DisposeBag()
    
    init(locationManager: PLocationManager, searchService: BLTweetSearchService) {
        _locationManager = locationManager
        _searchService = searchService
    }
    
    func start() {
        _locationManager.currentLocation.subscribe(onNext: { [weak self] location in
            guard let _self = self else { return }
            _self._lastLocation = location
            _self.location.onNext(location)
            _self.load(with: location, radius: _self.currentRadius)
            
        }).disposed(by: _disposeBag)
    }
    
    private func load(with location: CLLocation, radius: Int) {
        self._searchService.searchTweets(radius: self.currentRadius, location: location, completion: { [weak self] result in
            switch result {
            case .success(let tweets):
                print("got \(tweets.count) filteredTweets")
                self?.tweets.onNext(tweets)
            case .failure(let error):
                print(error as Any)
            }
        }) { tweet -> Bool in
            return tweet.place != nil
        }
    }
}
