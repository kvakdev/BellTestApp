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

protocol PSearchDataSource: UITableViewDataSource, UITableViewDelegate {
    func setup(tableView: UITableView)
    func set(tweets: [TWTRTweet])
}

class SearchDataSource: NSObject, PSearchDataSource {
    var selectedTweet: PublishSubject<TWTRTweet> = .init()
    
    private var tweets: [TWTRTweet] = []
    private weak var _tableView: UITableView!
    private let reuseId = "reuseId"
    
    func setup(tableView: UITableView) {
        tableView.tableFooterView = UIView()
        tableView.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: reuseId)
        _tableView = tableView
    }
    
    func set(tweets: [TWTRTweet]) {
        self.tweets = tweets
        _tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return tweets.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweet = self.tweets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! TWTRTweetTableViewCell
        
        cell.configure(with: tweet)
        cell.tweetView.delegate = self
        
        return cell
    }
}

extension SearchDataSource: TWTRTweetViewDelegate {
    func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
        self.selectedTweet.onNext(tweet)
    }
}
