//
//  SearchViewModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import TwitterKit

protocol PSearchViewModel: PViewModel {
    var dataSource: PSearchDataSource { get }
    var isLoaderVisible: PublishSubject<Bool> { get }
    
    func didChangeQuery(_ query: String)
}

class SearchViewModel: PSearchViewModel {
    var isLoaderVisible: PublishSubject<Bool> = .init()
    
    private var _model: PSearchModel
    private let _coordinator: PAppCoordinator
    
    private let _disposeBag = DisposeBag()
    var dataSource: PSearchDataSource {
        return _dataSource
    }
    private var _dataSource: SearchDataSource = SearchDataSource()
    
    init(_ model: PSearchModel, coordinator: PAppCoordinator) {
        _model = model
        _coordinator = coordinator
    }

    func viewDidLoad() {
        _dataSource.selectedTweet.subscribe(onNext: { tweet in
            self._coordinator.didSelect(tweet.tweetID)
        }).disposed(by: _disposeBag)
    }
    
    func didChangeQuery(_ query: String) {
        self.isLoaderVisible.onNext(true)
        
        _model.search(query: query) { [weak self] result in
            self?.isLoaderVisible.onNext(false)
            
            switch result {
            case .failure(let error):
                self?._coordinator.handle(error: error ?? NSError.noData())
            case .success(let tweets):
                self?.setTweets(tweets)
            }
        }
    }
    
    func setTweets(_ tweets: [TWTRTweet]) {
        dataSource.set(tweets: tweets)
    }
}
