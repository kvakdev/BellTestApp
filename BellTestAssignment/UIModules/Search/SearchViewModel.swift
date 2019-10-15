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

public protocol SearchViewModelProtocol: ViewModelProtocol {
    var dataSource: SearchDataSourceProtocol { get }
    var isLoaderVisible: PublishSubject<Bool> { get }
    
    func didChangeQuery(_ query: String)
}

public protocol SearchViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: SearchViewModel, didSelect tweet: TWTRTweet)
    func viewModel(_ viewModel: SearchViewModel, handle error: Error)
}

public class SearchViewModel: SearchViewModelProtocol {
    private weak var delegate: SearchViewModelDelegate?

    private var model: SearchModelProtocol
    private let disposeBag = DisposeBag()

    public var dataSource: SearchDataSourceProtocol = SearchDataSource()
    public var isLoaderVisible: PublishSubject<Bool> = .init()

    init(delegate: SearchViewModelDelegate, model: SearchModelProtocol) {
        self.delegate = delegate
        self.model = model
    }

    public func viewDidLoad() {
        dataSource.selectedTweet.subscribe(onNext: { [weak self] tweet in
            guard let self = self else { return }
            self.delegate?.viewModel(self, didSelect: tweet)
        }).disposed(by:disposeBag)
    }
    
    public func didChangeQuery(_ query: String) {
        self.isLoaderVisible.onNext(true)
        
        model.search(query: query) { [weak self] result in
            guard let self = self else { return }
            self.isLoaderVisible.onNext(false)
            
            switch result {
            case .failure(let error):
                self.delegate?.viewModel(self, handle: error ?? NSError.noData())
            case .success(let tweets):
                self.setTweets(tweets)
            }
        }
    }
    
    private func setTweets(_ tweets: [TWTRTweet]) {
        dataSource.set(tweets: tweets)
    }
}
