//
//  SearchTableDataSource.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import RxSwift
import TwitterKit

public protocol SearchDataSourceProtocol: UITableViewDataSource, UITableViewDelegate {
    var selectedTweet: PublishSubject<TWTRTweet> { get }

    func setup(tableView: UITableView)
    func set(tweets: [TWTRTweet])
}

public class SearchDataSource: NSObject, SearchDataSourceProtocol {
    private weak var tableView: UITableView!

    private var tweets: [TWTRTweet] = []
    private let reuseId = "reuseId"

    public var selectedTweet: PublishSubject<TWTRTweet> = .init()

    public func setup(tableView: UITableView) {
        tableView.tableFooterView = UIView()
        tableView.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: reuseId)
        self.tableView = tableView
    }
    
    public func set(tweets: [TWTRTweet]) {
        self.tweets = tweets
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return tweets.count
    }
     
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweet = self.tweets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! TWTRTweetTableViewCell
        
        cell.configure(with: tweet)
        cell.tweetView.delegate = self
        
        return cell
    }
}

// MARK: TWTRTweetViewDelegate funcs
extension SearchDataSource: TWTRTweetViewDelegate {
    public func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
        self.selectedTweet.onNext(tweet)
    }
}
