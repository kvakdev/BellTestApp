//
//  DetailViewModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import TwitterKit

public protocol DetailViewModelProtocol: ViewModelProtocol {
    var isLoaderVisible: PublishSubject<Bool> { get }
    var tweet: PublishSubject<TWTRTweet> { get }
    
    func retweetTapped()
    func likeTapped()
}

public protocol DetailViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: DetailViewModel, handle error: Error)
    func viewModel(_ viewModel: DetailViewModel, handle success: String)
}

public class DetailViewModel: DetailViewModelProtocol {
    public var isLoaderVisible: PublishSubject<Bool> = .init()
    public var tweet: PublishSubject<TWTRTweet> = .init()
    
    private let model: DetailModelProtocol
    private let twitter: TWTRTwitter
    private let disposeBag = DisposeBag()

    private weak var delegate: DetailViewModelDelegate?

    private let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        return dateFormatter
    }()
    
    public init(delegate: DetailViewModelDelegate, model: DetailModelProtocol, twitter: TWTRTwitter) {
        self.model = model
        self.delegate = delegate
        self.twitter = twitter
    }
    
    public func viewDidLoad() {
        isLoaderVisible.onNext(true)
        
        model.tweet.do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.isLoaderVisible.onNext(false)
        }).subscribe(
            onNext: { [weak self] tweet in
                guard let self = self else { return }
                self.tweet.onNext(tweet)
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                self.delegate?.viewModel(self, handle: error)
        }).disposed(by: disposeBag)
        
        model.loadDetails()
    }
    
    public func retweetTapped() {
        self.model.retweet { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.delegate?.viewModel(self, handle: "Retweet successfull!")
            case .failure(let error):
                guard let error = error else { return }
                self.delegate?.viewModel(self, handle: error)
            }
        }
    }
    
    public func likeTapped() {
        self.model.like { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.delegate?.viewModel(self, handle: "Like successfull!")
            case .failure(let error):
                guard let error = error else { return }
                self.delegate?.viewModel(self, handle: error)
            }
        }
    }
}
