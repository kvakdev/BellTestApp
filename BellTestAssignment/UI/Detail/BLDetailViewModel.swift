//
//  BLDetailViewModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import TwitterKit

protocol PDetailViewModel: PViewModel {
    var isLoaderVisible: PublishSubject<Bool> { get }
    var tweet: PublishSubject<TWTRTweet> { get }
    
    var timestamp: PublishSubject<String> { get }
}

class BLDetailViewModel: PDetailViewModel {
    var timestamp: PublishSubject<String> = .init()
    var isLoaderVisible: PublishSubject<Bool> = .init()
    var tweet: PublishSubject<TWTRTweet> = .init()
    var authorName: PublishSubject<String> = .init()
    
    private let _model: PDetailModel
    private let _coordinator: PCoordinator
    private let _disposeBag = DisposeBag()
    
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        
        return f
    }()
    
    init(_ model: PDetailModel, coordinator: PCoordinator) {
        _model = model
        _coordinator = coordinator
    }
    
    func viewDidLoad() {
        isLoaderVisible.onNext(true)
        
        _model.tweet.subscribe(onNext: { [weak self] tweet in
            guard let _self = self else { return }
            _self.tweet.onNext(tweet)
            _self.timestamp.onNext(_self.formatter.string(from: tweet.createdAt))
        }, onError: { [weak self] error in
            self?._coordinator.handle(error: error)
        }).disposed(by: _disposeBag)
        
        _model.loadDetails()
    }
}
