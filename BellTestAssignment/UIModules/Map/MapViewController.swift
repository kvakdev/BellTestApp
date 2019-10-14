//
//  MapViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import CoreLocation

protocol PMapViewModel: PViewModel {
    var tweets: PublishSubject<[Tweet]> { get }
    var location: PublishSubject<CLLocation> { get }
    var isLoggedIn: PublishSubject<Bool> { get }
    
    func didTapDetails(tweet: Tweet)
    func didChangeRadius(_ radius: Int)
    func didTapSearch()
    func didTapLogout()
    func didTapLogin()
}

class MapViewController: BaseVC {
    private var viewModel: PMapViewModel {
        return self.vModel as! PMapViewModel
    }
    
    @IBOutlet private weak var _mapView: MKMapView!
    @IBOutlet private weak var _radiusSlider: UISlider!
    
    private let identifier = "reuseId"
    private var _radiusKm: Int = 5
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupMapView()
        setupSlider()
        setupCallbacks()
        
        super.viewDidLoad()
    }
    
    deinit {
        print("deinit")
    }
    
    // MARK: - Private funcs
    private func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearchBtn))
        updateTitle()
    }
    
    private func makeLeftBarButton(_ isLoggedIn: Bool) {
        let title = isLoggedIn ? "Logout" : "Login"
        let selector: Selector = isLoggedIn ? #selector(handleLogoutBtn) : #selector(handleLoginBtn)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
    }
    
    @objc private func handleLoginBtn() {
        viewModel.didTapLogin()
    }
    
    @objc private func handleLogoutBtn() {
        viewModel.didTapLogout()
    }
    
    @objc private func handleSearchBtn() {
        viewModel.didTapSearch()
    }
    
    @objc private func handleValueChanged(_ sender: UISlider) {
        _radiusKm = Int(sender.value)
        updateTitle()
        viewModel.didChangeRadius(_radiusKm)
    }
    private func updateTitle() {
        navigationItem.title = "Radius search: \(_radiusKm) km"
    }
    
    private func setupMapView() {
        _mapView.showsScale = true
        _mapView.delegate = self
        _mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
    }
    
    private func setupSlider() {
        _radiusSlider.addTarget(self, action: #selector(handleValueChanged(_:)), for: .valueChanged)
        _radiusSlider.isContinuous = false
        _radiusSlider.setValue(Float(_radiusKm), animated: false)
    }
    
    private func setupCallbacks() {
        self.viewModel.tweets.subscribe(onNext: { [weak self] tweets in
            DispatchQueue.main.async {
                self?._mapView.removeOldPins()
                self?._mapView.makePins(for: tweets)
            }
        }).disposed(by: self.disposeBag)
        
        self.viewModel.location.subscribe(onNext: { location in
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, span: span)
            self._mapView.setRegion(coordinateRegion, animated: true)
        }).disposed(by: disposeBag)
        
        self.viewModel.isLoggedIn.subscribe(onNext: { isLoggedIn in
            self.makeLeftBarButton(isLoggedIn)
        }).disposed(by: disposeBag)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? TweetAnnotation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView!.annotation = annotation
        }
        
        annotationView?.canShowCallout = true
        annotationView?.calloutOffset = CGPoint(x: -5, y: 5)
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let note = view.annotation as? TweetAnnotation {
            debugPrint("tapped \(note.tweet.author.screenName)")
            
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let tweetAnnotation = view.annotation as? TweetAnnotation {
            let tweet = tweetAnnotation.tweet
            viewModel.didTapDetails(tweet: tweet)
        }
    }
}
