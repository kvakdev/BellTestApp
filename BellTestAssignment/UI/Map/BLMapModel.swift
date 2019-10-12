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
    
    var currentRadius: Int = 5
    
    private let _disposeBag = DisposeBag()
    
    init(locationManager: PLocationManager, searchService: BLTweetSearchService) {
        _locationManager = locationManager
        _searchService = searchService
    }
    
    func start() {
        _locationManager.currentLocation.subscribe(onNext: { [weak self] location in
            guard let _self = self else { return }
            
            _self.location.onNext(location)
            
            _self._searchService.searchTweets(radius: _self.currentRadius, location: location, completion: { result in
                switch result {
                case .success(let tweets):
                    print(tweets)
                    self?.tweets.onNext(tweets)
                case .failure(let error):
                    print(error as Any)
                }
            }) { tweet -> Bool in
                return tweet.place != nil
            }
        }).disposed(by: _disposeBag)
    }
}
