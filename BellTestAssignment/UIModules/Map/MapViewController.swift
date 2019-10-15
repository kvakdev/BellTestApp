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


public class MapViewController: BaseViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var radiusSlider: UISlider!
    
    private let identifier = "reuseId"
    private var radiusKm: Int = 5

    private var viewModel: MapViewModelProtocol {
        return self.vModel as! MapViewModelProtocol
    }

    override public func viewDidLoad() {
        setupNavigationBar()
        setupMapView()
        setupSlider()
        setupCallbacks()

        super.viewDidLoad()
    }
    
    // MARK: - Private funcs
    private func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearchBtn))
        updateTitle()
    }

    private func updateTitle() {
        navigationItem.title = "Radius search: \(radiusKm) km"
    }
    
    private func setupMapView() {
        mapView.showsScale = true
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
    }
    
    private func setupSlider() {
        radiusSlider.isContinuous = false
        radiusSlider.setValue(Float(radiusKm), animated: false)
    }
    
    private func setupCallbacks() {
        self.viewModel.tweets.subscribe(onNext: { [weak self] tweets in
            DispatchQueue.main.async {
                self?.mapView.removeOldPins()
                self?.mapView.makePins(for: tweets)
            }
        }).disposed(by: self.disposeBag)
        
        self.viewModel.location.subscribe(onNext: { [weak self] location in
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, span: span)
            self?.mapView.setRegion(coordinateRegion, animated: true)
        }).disposed(by: disposeBag)
    }

    // MARK: Private actions
    @objc private func handleSearchBtn() {
        viewModel.didTapSearch()
    }

    @IBAction private func handleValueChanged(_ sender: UISlider) {
        radiusKm = Int(sender.value)
        updateTitle()
        viewModel.didChangeRadius(radiusKm)
    }
}

// MARK: MKMapViewDelegate funcs
extension MapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let note = view.annotation as? TweetAnnotation else { return }
        debugPrint("tapped \(note.tweet.author.screenName)")
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let tweetAnnotation = view.annotation as? TweetAnnotation else { return }
        let tweet = tweetAnnotation.tweet
        viewModel.didTapDetails(tweet: tweet)
    }
}
