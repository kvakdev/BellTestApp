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

protocol PMapViewModel: PViewModel {
    var tweets: PublishSubject<[Tweet]> { get }
    var location: PublishSubject<CLLocation> { get }
    var isLoggedIn: PublishSubject<Bool> { get }
    
    func didTapDetails(tweet: Tweet)
    func didChangeRadius(_ radius: Int)
    func didTapSearch()
    func didTapLogout()
    func didTapLogin()
}


public class MapViewModel: PMapViewModel {
    var tweets: PublishSubject<[Tweet]> = .init()
    var isLoggedIn: PublishSubject<Bool> = .init()
    var location: PublishSubject<CLLocation> {
        return model.location
    }
    public var tweetCapacity: Int = 100
    public var timerInterval: TimeInterval = 60
    
    private var model: PMapModel
    private let coordinator: PCoordinator
    private let disposeBag = DisposeBag()
    private var tweetAccumulator: [Tweet] = []
    
    private var timer: Timer?
    
    init(_ model: PMapModel, coordinator: PCoordinator) {
        self.model = model
        self.coordinator = coordinator
    }
    
    public func viewDidLoad() {
        model.tweets.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] tweets in
            self?.tweetAccumulator = tweets
            self?.tweets.onNext(tweets)
            self?.restartTimer()
        }).disposed(by: disposeBag)
        
        model.presentableError.subscribe(onNext: { [weak self] error in
            self?.coordinator.handle(error: error)
        }).disposed(by: disposeBag)
        
        isLoggedIn.onNext(coordinator.isLoggedIn)
        
        model.accumulatableTweets.subscribe(onNext: { [weak self] tweets in
            self?.handleAccumulatable(tweets)
        }).disposed(by: disposeBag)
        
        model.start()
    }
    
    public func viewWillAppear() {
        isLoggedIn.onNext(coordinator.isLoggedIn)
    }
    
    func didTapDetails(tweet: Tweet) {
        self.coordinator.didSelect(tweet.id)
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
    
    private func handleAccumulatable(_ tweets: [Tweet]) {
        guard !tweets.isEmpty else { return }
        
        tweetAccumulator.append(contentsOf: tweets)
        let result: Array = tweetAccumulator
            .suffix(tweetCapacity)
            .sorted { $0.sortIndex < $1.sortIndex }
        
        self.tweetAccumulator = result
        self.tweets.onNext(result)
    }
    
    private func restartTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { timer in
            guard let last = self.tweetAccumulator.last else { return }
            self.model.fetchAfter(id: last.id)
        })
    }
}
