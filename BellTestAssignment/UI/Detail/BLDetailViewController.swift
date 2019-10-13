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
    
    @IBOutlet private weak var _likeButton: UIButton!
    @IBOutlet private weak var _retweetButton: UIButton!
    @IBOutlet private weak var _btnsContainer: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Details"
        setupBtns()
        
        self.viewModel.tweet.subscribe(onNext: { [weak self] tweet in
            self?.addTweetView(tweet)
        }).disposed(by: disposeBag)
    }
    
    func addTweetView(_ tweet: TWTRTweet) {
        let twitterView = TWTRTweetView(tweet: tweet, style: TWTRTweetViewStyle.compact)
        twitterView.backgroundColor = .clear
        view.addSubview(twitterView)
        
        twitterView.translatesAutoresizingMaskIntoConstraints = false
        twitterView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        twitterView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        twitterView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        twitterView.bottomAnchor.constraint(lessThanOrEqualTo: _btnsContainer.topAnchor).isActive = true
        twitterView.delegate = self
    }
    
    private func setupBtns() {
        [_likeButton, _retweetButton].forEach { $0?.addTarget(self, action: #selector(handleBtnAction(_:)), for: .touchUpInside) }
    }
    
    @objc func handleBtnAction(_ sender: UIButton) {
        switch sender {
        case _retweetButton:
            viewModel.retweetTapped()
        case _likeButton:
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
