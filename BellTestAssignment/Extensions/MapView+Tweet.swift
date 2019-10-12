//
//  MapView+Tweet.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import MapKit

extension MKMapView {
    func makePins(for tweets: [BLTweet]) {
        let annotations = tweets.compactMap { BLTweetAnnotation(tweet: $0) }
//        addAnnotations(annotations)
        showAnnotations(annotations, animated: true)
    }
}

class BLTweetAnnotation: MKPointAnnotation {
//    var coordinate: CLLocationCoordinate2D
    let tweet: BLTweet
    
    init?(tweet: BLTweet) {
        self.tweet = tweet
        guard let lat = tweet.place?.boundingBox.coordinates.first?.first?.last,
            let lon = tweet.place?.boundingBox.coordinates.first?.first?.first
            else { return nil }
        super.init()
        
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
   
}

