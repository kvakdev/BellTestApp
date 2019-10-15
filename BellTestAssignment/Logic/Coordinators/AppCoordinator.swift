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

public protocol AppCoordinatorProtocol {
    func startAuthFlow()
    func showInitialFlow()
}

public class AppCoordinator {
    private let navigationController: UINavigationController

    private var client = APIClientWrapper(client: TWTRAPIClient.withCurrentUser())
    private var loginCoordinator: LoginCoordinator?

    var currentViewController: UIViewController? {
        return navigationController.viewControllers.last
    }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: Private funcs
private extension AppCoordinator {
    func showSettingsAlert() {
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

    func handle(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        currentViewController?.present(alert, animated: true, completion: nil)
    }

    func handleSuccess(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        currentViewController?.present(alert, animated: true, completion: nil)
    }

    func showTweet(id: String) {
        let viewController = DetailViewController()
        let service = TweetSearchService(client: client)
        let model = DetailModel(tweetId: id, searchService: service)
        let viewModel = DetailViewModel(delegate: self, model: model, twitter: TWTRTwitter.sharedInstance())

        viewController.set(vModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: MapViewModelDelegate func
extension AppCoordinator: MapViewModelDelegate {
    func viewModel(_ viewModel: MapViewModel, didSelect tweet: Tweet) {
        showTweet(id: tweet.id)
    }

    func viewModel(_ viewModel: MapViewModel, handle error: Error) {
        handle(error: error)
    }

    func viewModelDidMoveSlider(_ viewModel: MapViewModel) {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            showSettingsAlert()
        }
    }

    func viewModelDidTapSearch(_ viewModel: MapViewModel) {
        let vc = SearchViewController()
        let model = SearchModel(TweetSearchService(client: client))
        let viewModel = SearchViewModel(delegate: self, model: model)
        vc.navigationItem.title = "Search"
        vc.set(vModel: viewModel)

        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: SearchViewModelDelegate funcs
extension AppCoordinator: SearchViewModelDelegate {
    public func viewModel(_ viewModel: SearchViewModel, didSelect tweet: TWTRTweet) {
        showTweet(id: tweet.tweetID)
    }

    public func viewModel(_ viewModel: SearchViewModel, handle error: Error) {
        handle(error: error)
    }
}


// MARK: DetailViewModelDelegate funcs
extension AppCoordinator: DetailViewModelDelegate {
    public func viewModel(_ viewModel: DetailViewModel, handle error: Error) {
        handle(error: error)
    }

    public func viewModel(_ viewModel: DetailViewModel, handle success: String) {
        handleSuccess(message: success)
    }
}

// MARK: AppCoordinatorProtocol funcs
extension AppCoordinator: AppCoordinatorProtocol {
    public func startAuthFlow() {
        loginCoordinator = LoginCoordinator(delegate: self, navigationController: navigationController)
    }

    public func showInitialFlow() {
        let viewController = MapViewController()
        let location = LocationManager.shared
        let search = TweetSearchService(client: client)
        let model = MapModel(locationManager: location, searchService: search)

        let viewModel = MapViewModel(delegate: self, model: model)
        viewController.set(vModel: viewModel)

        self.navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: LoginCoordinatorDelegate funcs
extension AppCoordinator: LoginCoordinatorDelegate {
    public func coordinatorDidLogin(_ coordinator: LoginCoordinator) {
        showInitialFlow()
    }
    
    public func coordinator(_ coordinator: LoginCoordinator, didFailWith error: Error) {
        handle(error: error)
    }
}
