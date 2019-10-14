//
//  MainCoordinator.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

class BaseCoordinatorClass: NSObject {}

class BLMainCoordinator: BaseCoordinatorClass, PCoordinator {
    var currentViewController: UIViewController? {
        return navigationController.viewControllers.last
    }
    private var _children: [BaseCoordinatorClass] = []
    private let navigationController: UINavigationController
    private var client = TWTRAPIClient.withCurrentUser()
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func addChild(_ child: BaseCoordinatorClass) {
        _children.append(child)
    }

    func start() {
        self.navigationController.setViewControllers([makeMapView()], animated: false)
    }
    func finish() {}
    
    func coordinatorIsDone(_ child: BaseCoordinatorClass) {
        let index = _children.enumerated().first { $0.element === child }?.offset
        
        if let index = index {
            _children.remove(at: index)
        }
        
        if let coordinator = child as? BaseCoordinator {
            coordinator.finish()
        }
        
        start()
    }
    
    private func makeMapView() -> UIViewController {
        let vc = BLMapViewController()
        let location = BLLocationManager.shared
        let search = BLTweetSearchService(client: client)
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
    
    func handleSuccess(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
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
        let service = BLTweetSearchService(client: client)
        let model = BLDetailModel(tweetId: tweetId, searchService: service)
        let viewModel = BLDetailViewModel(model, coordinator: self, twitter: TWTRTwitter.sharedInstance())
        
        vc.set(vModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didTapSearch() {
        let vc = BLSearchViewController()
        let model = BLSearchModel(BLTweetSearchService(client: client))
        let viewModel = BLSearchViewModel(model, coordinator: self)
        vc.navigationItem.title = "Search"
        vc.set(vModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }
}
