//
//  BLMapViewController.swift
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
    var tweets: PublishSubject<[BLTweet]> { get }
    var location: PublishSubject<CLLocation> { get }
}

class BLMapViewController: BLBaseVC {
    private var viewModel: PMapViewModel {
        return self.vModel as! PMapViewModel
    }
    
    @IBOutlet private weak var _mapView: MKMapView!
    private let identifier = "reuseId"
    private var _radiusKm: Double = 5
    private var _radiusMeters: Double { return self._radiusKm * 1000 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _mapView.delegate = self
        _mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        
        self.viewModel.tweets.subscribe(onNext: { [weak self] tweets in
            DispatchQueue.main.async {
                self?._mapView.makePins(for: tweets)
            }
        }).disposed(by: self.disposeBag)
        
        self.viewModel.location.subscribe(onNext: { location in
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
            let coordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1,
                                                                                   longitudeDelta: 0.1))
            self._mapView.setRegion(coordinateRegion, animated: true)
        }).disposed(by: disposeBag)
    }
    
    deinit {
        print("deinit")
    }
}

extension BLMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? BLTweetAnnotation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        debugPrint("tapped \(view.tag)")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
          let circle = MKCircleRenderer(overlay: overlay)
          circle.strokeColor = .red
          circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
          circle.lineWidth = 1
          return circle
      }
}
