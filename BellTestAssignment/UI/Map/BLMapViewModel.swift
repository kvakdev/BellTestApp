//
//  BLMapViewModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation
import TwitterKit

class BLMapViewModel: PMapViewModel {
    var tweets: PublishSubject<[BLTweet]> = .init()
    var location: PublishSubject<CLLocation> {
        return _model.location
    }
    
    private var _model: PMapModel
    private let _coordinator: PCoordinator
    
    private let _disposeBag = DisposeBag()
    
    init(_ model: PMapModel, coordinator: PCoordinator) {
        _model = model
        _coordinator = coordinator
    }
    
    func viewDidLoad() {
        _model.tweets.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] tweets in
            self?.tweets.onNext(tweets)
        }, onError: { [weak self] error in
            self?._coordinator.handle(error: error)
        }).disposed(by: _disposeBag)
        
        _model.start()
    }
    
    func didTapDetails(tweet: BLTweet) {
        self._coordinator.didSelect(tweet)
    }
    
    func didChangeRadius(_ radius: Int) {
        _model.currentRadius = radius
    }
    
    func didTapSearch() {
        _coordinator.didTapSearch()
    }

}
