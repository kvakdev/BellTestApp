//
//  MainCoordinator.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit
import CoreLocation

class APIClientWrapper: PTwitterClient {
    private var client: PTwitterClient
    
    init(client: PTwitterClient) {
        self.client = client
    }
    
    func refresh() {
        self.client = TWTRAPIClient.withCurrentUser()
    }
    
    func urlRequest(with method: HTTPMethod, endpoint: Endpoints, params: [String : Any]) -> URLRequest {
        return client.urlRequest(with: method, endpoint: endpoint, params: params)
    }
    
    func urlRequest(with method: HTTPMethod, urlString: String, params: [String : Any]) -> URLRequest {
        return client.urlRequest(with: method, urlString: urlString, params: params)
    }
    
    func sendRequest(_ request: URLRequest, completion: @escaping (URLResponse?, Data?, Error?) -> Void) {
        client.sendRequest(request, completion: completion)
    }
    
    func loadOneTweet(withID id: String, completion: @escaping (TWTRTweet?, Error?) -> Void) {
        client.loadOneTweet(withID: id, completion: completion)
    }
}

class AppCoordinator: BaseCoordinatorClass, PCoordinator {
    var isLoggedIn: Bool {
        return twitter.sessionStore.session() != nil
    }
    
    var currentViewController: UIViewController? {
        return navigationController.viewControllers.last
    }
    private var _children: [BaseCoordinatorClass] = []
    private let navigationController: UINavigationController
    private var client = APIClientWrapper(client: TWTRAPIClient.withCurrentUser())
    private let twitter = TWTRTwitter.sharedInstance()
    
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
        let vc = MapViewController()
        let location = LocationManager.shared
        let search = TweetSearchService(client: client)
        let model = MapModel(locationManager: location, searchService: search)
        
        let viewModel = MapViewModel(model, coordinator: self)
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
    
    func didSelect(_ tweet: Tweet) {
        pushDetailViewController(tweetId: tweet.id)
    }
    
    func didSelect(_ tweetId: String) {
        pushDetailViewController(tweetId: tweetId)
    }
    
    private func pushDetailViewController(tweetId: String) {
        let vc = DetailViewController()
        let service = TweetSearchService(client: client)
        let model = DetailModel(tweetId: tweetId, searchService: service)
        let viewModel = DetailViewModel(model, coordinator: self, twitter: TWTRTwitter.sharedInstance())
        
        vc.set(vModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didTapSearch() {
        let vc = SearchViewController()
        let model = SearchModel(TweetSearchService(client: client))
        let viewModel = SearchViewModel(model, coordinator: self)
        vc.navigationItem.title = "Search"
        vc.set(vModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didTapLogout(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "Please confirm?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .cancel, handler: { _ in
            if let userId = self.twitter.sessionStore.session()?.userID {
                self.twitter.sessionStore.logOutUserID(userId)
                completion(true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        currentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func didTapLogin(completion: @escaping (Bool) -> Void) {
        twitter.logIn { session, error in
            self.client.refresh()
            self.handle(error: error)
            completion(session != nil)
        }
    }
    
    func didMoveSlider() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            showSettingsAlert()
        }
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: nil, message: "Allow the app to access your location?", preferredStyle: .alert)
        let allowAction = UIAlertAction(title: "Allow", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let laterAction = UIAlertAction(title: "Later", style: .cancel, handler: nil)
        
        alert.addAction(allowAction)
        alert.addAction(laterAction)
        
        currentViewController?.present(alert, animated: true, completion: nil)
    }
}
