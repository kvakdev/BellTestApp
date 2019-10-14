//
//  BLDetailViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

class BLDetailViewController: BLBaseVC {
    private var viewModel: PDetailViewModel {
        return self.vModel as! PDetailViewModel
    }
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var retweetButton: UIButton!
    @IBOutlet private weak var btnsContainer: UIStackView!
    private let loader = UIActivityIndicatorView(style: .gray)
    private var tweetView: TWTRTweetView?
    
    override func viewDidLoad() {
        self.navigationItem.title = "Details"
        
        setupLoader()
        setupBtns()
        setupCallbacks()
        
        super.viewDidLoad()
    }
    
    private func setupCallbacks() {
        self.viewModel.tweet.subscribe(onNext: { [weak self] tweet in
            self?.addTweetView(tweet)
        }).disposed(by: disposeBag)
        
        viewModel.isLoaderVisible.subscribe(onNext: { [weak self] visible in
            if visible {
                self?.loader.startAnimating()
            } else {
                self?.loader.stopAnimating()
            }
        }).disposed(by: disposeBag)
    }
    
    private func addTweetView(_ tweet: TWTRTweet) {
        tweetView?.removeFromSuperview()
        
        let tweetView = TWTRTweetView(tweet: tweet, style: TWTRTweetViewStyle.compact)
        tweetView.backgroundColor = .clear
        view.addSubview(tweetView)
        
        tweetView.translatesAutoresizingMaskIntoConstraints = false
        tweetView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tweetView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tweetView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tweetView.bottomAnchor.constraint(lessThanOrEqualTo: btnsContainer.topAnchor).isActive = true
        tweetView.delegate = self
        
        self.tweetView = tweetView
    }
    
    private func setupBtns() {
        [likeButton, retweetButton].forEach { $0?.addTarget(self, action: #selector(handleBtnAction(_:)), for: .touchUpInside) }
    }
    
    private func setupLoader() {
        view.addSubview(loader)
        loader.center = self.view.center
        loader.hidesWhenStopped = true
    }
    
    @objc func handleBtnAction(_ sender: UIButton) {
        switch sender {
        case retweetButton:
            viewModel.retweetTapped()
        case likeButton:
            viewModel.likeTapped()
        default:
            assertionFailure()
        }
    }
}

extension BLDetailViewController: TWTRTweetViewDelegate {
    func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
        print("Tweet tapped doign nothing")
    }
}
