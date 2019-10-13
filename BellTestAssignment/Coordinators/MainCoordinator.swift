//
//  MainCoordinator.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

class BLMainCoordinator: PCoordinator {
    
    var currentViewController: UIViewController? {
        return navigationController.viewControllers.last
    }
    
    private let navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        self.navigationController.setViewControllers([makeMapView()], animated: false)
    }

    private func makeMapView() -> UIViewController {
        let vc = BLMapViewController()
        let location = BLLocationManager.shared
        let search = BLTweetSearchService()
        let model = BLMapModel(locationManager: location, searchService: search)
        
        let viewModel = BLMapViewModel(model, coordinator: self)
        vc.set(vModel: viewModel)
        
        return vc
    }
    
    func handle(error: Error?) {
        guard let error = error else { return }
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        currentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func didSelect(_ tweet: BLTweet) {
        pushDetailViewController(tweetId: tweet.id)
    }
    
    func didSelect(_ tweet: TWTRTweet) {
        pushDetailViewController(tweetId: tweet.tweetID)
    }
    
    private func pushDetailViewController(tweetId: String) {
        let vc = BLDetailViewController()
        let service = BLTweetSearchService()
        let model = BLDetailModel(tweetId: tweetId, searchService: service)
        let viewModel = BLDetailViewModel(model, coordinator: self, twitter: TWTRTwitter.sharedInstance())
        
        vc.set(vModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didTapSearch() {
        let vc = BLSearchViewController()
        let model = BLSearchModel(BLTweetSearchService())
        let viewModel = BLSearchViewModel(model, coordinator: self)
        vc.navigationItem.title = "Search"
        vc.set(vModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }
}
