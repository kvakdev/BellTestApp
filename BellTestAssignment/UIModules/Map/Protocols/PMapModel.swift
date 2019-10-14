//
//  PMapModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

public protocol PMapModel {
    var currentRadius: Int { get set }
    var tweets: PublishSubject<[Tweet]> { get }
    var accumulatableTweets: PublishSubject<[Tweet]> { get }
    var location: PublishSubject<CLLocation> { get }
    var presentableError: PublishSubject<Error> { get }

    func start()
    func fetchAfter(id: String)
}
