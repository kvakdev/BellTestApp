//
//  DetailViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

public class DetailViewController: BaseViewController {
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var retweetButton: UIButton!
    @IBOutlet private weak var btnsContainer: UIStackView!

    private let loader = UIActivityIndicatorView(style: .gray)
    private var tweetView: TWTRTweetView?

    private var viewModel: DetailViewModelProtocol {
        return self.vModel as! DetailViewModelProtocol
    }

    override public func viewDidLoad() {
        self.navigationItem.title = "Details"

        setupButtons()
        setupLoader()
        setupCallbacks()

        super.viewDidLoad()
    }

    private func setupButtons() {
        likeButton.layer.borderColor = UIColor.blue.cgColor
        likeButton.layer.borderWidth = 1

        retweetButton.layer.borderColor = UIColor.blue.cgColor
        retweetButton.layer.borderWidth = 1
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
    
    private func setupLoader() {
        view.addSubview(loader)
        loader.center = self.view.center
        loader.hidesWhenStopped = true
    }

    @IBAction private func retweet() {
        viewModel.retweetTapped()
    }

    @IBAction private func like() {
        viewModel.likeTapped()
    }
}

// MARK: TWTRTweetViewDelegate funcs
extension DetailViewController: TWTRTweetViewDelegate {
    public func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
        print("Tweet tapped doign nothing")
    }
}
