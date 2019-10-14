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

protocol PDetailViewModel: PViewModel {
    var isLoaderVisible: PublishSubject<Bool> { get }
    var tweet: PublishSubject<TWTRTweet> { get }
    
    func retweetTapped()
    func likeTapped()
}

class DetailViewModel: PDetailViewModel {
    var isLoaderVisible: PublishSubject<Bool> = .init()
    var tweet: PublishSubject<TWTRTweet> = .init()
    
    private let model: PDetailModel
    private let coordinator: PAppCoordinator
    private let twitter: TWTRTwitter
    private let disposeBag = DisposeBag()
    
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        
        return f
    }()
    
    init(_ model: PDetailModel, coordinator: PAppCoordinator, twitter: TWTRTwitter) {
        self.model = model
        self.coordinator = coordinator
        self.twitter = twitter
    }
    
    func viewDidLoad() {
        isLoaderVisible.onNext(true)
        
        model.tweet.do(onNext: { _ in
            self.isLoaderVisible.onNext(false)
        }).subscribe(onNext: { [weak self] tweet in
            guard let _self = self else { return }
            
            _self.tweet.onNext(tweet)
        }, onError: { [weak self] error in
            self?.coordinator.handle(error: error)
        }).disposed(by: disposeBag)
        
        model.loadDetails()
    }
    
    func retweetTapped() {
        ensureIsLoggedIn { [unowned self] in
            
            self.model.retweet { result in
                switch result {
                case .success:
                    self.coordinator.handleSuccess(message: "Retweet successfull!")
                case .failure(let error):
                    self.coordinator.handle(error: error)
                }
            }
        }
    }
    
    func likeTapped() {
        ensureIsLoggedIn { [unowned self] in
            
            self.model.like { result in
                switch result {
                case .success:
                    self.coordinator.handleSuccess(message: "Like successfull!")
                case .failure(let error):
                    self.coordinator.handle(error: error)
                }
            }
        }
    }
    
    private func ensureIsLoggedIn(completion: @escaping () -> Void) {
        if twitter.sessionStore.hasLoggedInUsers() {
            completion()
            return
        } else {
            coordinator.didTapLogin { loggedIn in
                if loggedIn {
                    completion()
                }
            }
            
//            twitter.logIn { [unowned self] (session, error) in
//                if session != nil {
//                    completion()
//                }
//                if let error = error {
//                    self.coordinator.handle(error: error)
//                }
//            }
        }
    }
}
