//
//  MapViewModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation
import TwitterKit

class MapViewModel: PMapViewModel {
    var tweets: PublishSubject<[Tweet]> = .init()
    var isLoggedIn: PublishSubject<Bool> = .init()
    var location: PublishSubject<CLLocation> {
        return model.location
    }
    
    private var model: PMapModel
    private let coordinator: PCoordinator
    private let disposeBag = DisposeBag()
    
    init(_ model: PMapModel, coordinator: PCoordinator) {
        self.model = model
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        model.tweets.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] tweets in
            self?.tweets.onNext(tweets)
        }).disposed(by: disposeBag)
        
        model.presentableError.subscribe(onNext: { [weak self] error in
            self?.coordinator.handle(error: error)
        }).disposed(by: disposeBag)
        
        isLoggedIn.onNext(coordinator.isLoggedIn)
        
        model.start()
    }
    
    func viewWillAppear() {
        isLoggedIn.onNext(coordinator.isLoggedIn)
    }
    
    func didTapDetails(tweet: Tweet) {
        self.coordinator.didSelect(tweet)
    }
    
    func didChangeRadius(_ radius: Int) {
        model.currentRadius = radius
    }
    
    func didTapSearch() {
        coordinator.didTapSearch()
    }
    
    func didTapLogout() {
        coordinator.didTapLogout { [unowned self] isLoggedOut in
            self.isLoggedIn.onNext(!isLoggedOut)
        }
    }
    
    func didTapLogin() {
        coordinator.didTapLogin { [unowned self] isLoggedIn in
            self.isLoggedIn.onNext(isLoggedIn)
        }
    }
}
