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

protocol MapViewModelProtocol: ViewModelProtocol {
    var tweets: PublishSubject<[Tweet]> { get }
    var location: PublishSubject<CLLocation> { get }

    func didTapDetails(tweet: Tweet)
    func didChangeRadius(_ radius: Int)
    func didTapSearch()
    func viewDidLoad()
}

protocol MapViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: MapViewModel, didSelect tweet: Tweet)
    func viewModel(_ viewModel: MapViewModel, handle error: Error)
    func viewModelDidMoveSlider(_ viewModel: MapViewModel)
    func viewModelDidTapSearch(_ viewModel: MapViewModel)
}

class MapViewModel {
    private var model: MapModelProtocol
    private let disposeBag = DisposeBag()
    private var tweetAccumulator: [Tweet] = []
    private var timer: Timer?

    private weak var delegate: MapViewModelDelegate?

    var tweets: PublishSubject<[Tweet]> = .init()
    var location: PublishSubject<CLLocation> {
        return model.location
    }

    var tweetCapacity: Int = 100
    var timerInterval: TimeInterval = 60

    init(delegate: MapViewModelDelegate, model: MapModelProtocol) {
        self.model = model
        self.delegate = delegate
    }

    // MARK: Private funcs
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

// MARK: MapViewModelProtocol funcs
extension MapViewModel: MapViewModelProtocol {
    func viewDidLoad() {
        model.tweets.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] tweets in
            self?.tweetAccumulator = tweets
            self?.tweets.onNext(tweets)
            self?.restartTimer()
        }).disposed(by: disposeBag)
        
        model.presentableError.subscribe(onNext: { [weak self] error in
            guard let self = self else { return }
            self.delegate?.viewModel(self, handle: error)
        }).disposed(by: disposeBag)

        model.accumulatableTweets.subscribe(onNext: { [weak self] tweets in
            self?.handleAccumulatable(tweets)
        }).disposed(by: disposeBag)
        
        model.start()
    }
    
    func didTapDetails(tweet: Tweet) {
        delegate?.viewModel(self, didSelect: tweet)
    }
    
    func didChangeRadius(_ radius: Int) {
        delegate?.viewModelDidMoveSlider(self)
        model.currentRadius = radius
    }
    
    func didTapSearch() {
        delegate?.viewModelDidTapSearch(self)
    }
}
