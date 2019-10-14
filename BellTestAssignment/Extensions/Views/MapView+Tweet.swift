//
//  MapView+Tweet.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import MapKit

extension MKMapView {
    func makePins(for tweets: [Tweet]) {
        let annotations = tweets.compactMap { TweetAnnotation(tweet: $0) }
        addAnnotations(annotations)
        showAnnotations(annotations, animated: true)
    }
    
    func removeOldPins() {
        removeAnnotations(annotations)
//        removeOverlays(overlays)
    }
}

class TweetAnnotation: MKPointAnnotation {
    let tweet: Tweet
    
    init?(tweet: Tweet) {
        self.tweet = tweet
        guard let lat = tweet.place?.boundingBox.coordinates.first?.first?.last,
            let lon = tweet.place?.boundingBox.coordinates.first?.first?.first
            else { return nil }
        super.init()
        self.title = "\(tweet.text)"
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
   
}

