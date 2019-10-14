//
//  MapViewModelTests.swift
//  BellTestAssignmentTests
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation


class MapViewModelTests: XCTestCase {
    private let disposeBag = DisposeBag()
    
    func test_viewDidLoad_triggersStart() {
        //given
        let (sut, modelSpy) = makeSUT()
        //when
        sut.viewDidLoad()
        //then
        XCTAssertTrue(modelSpy.startIsCalled)
    }
    
    func test_accumulatableTweets_accumulate() {
        let (sut, modelSpy) = makeSUT()
        let exp = expectation(description: "waiting for load to complete")
        var tweetsSent = [Tweet.anyTweet(with: 0)]
        let lastId = 22
        sut.tweets.subscribe(onNext: { tweets in
            XCTAssertEqual(tweetsSent, tweets)
            XCTAssertTrue(tweets.count <= 100)
            if tweets.last?.id == "\(lastId)"  { exp.fulfill() }
        }).disposed(by: disposeBag)
        
        sut.viewDidLoad()
        let firstPack = (1...11).compactMap { Tweet.anyTweet(with: $0) }
        let secondPack = (12...lastId).compactMap { Tweet.anyTweet(with: $0) }
        
        modelSpy.send(tweets: tweetsSent)
        tweetsSent.append(contentsOf: firstPack)
        modelSpy.send(tweets: firstPack)
        tweetsSent.append(contentsOf: secondPack)
        modelSpy.send(tweets: secondPack)
        
        wait(for: [exp], timeout: 5)
    }
    
    func test_accumulator_publishesCorrectAmount() {
        //given
        let (sut, modelSpy) = makeSUT()
        let exp = expectation(description: "waiting for load to complete")
        let capacity = sut.tweetCapacity
        
        sut.tweets.subscribe(onNext: { tweets in
            //then
            XCTAssertTrue(tweets.count <= capacity)
            exp.fulfill()
        }).disposed(by: disposeBag)
        //when
        sut.viewDidLoad()
        
        let thirdPack = (1...300).compactMap { Tweet.anyTweet(with: $0) }
        modelSpy.send(tweets: thirdPack)
        
        wait(for: [exp], timeout: 5)
    }
    
    func makeSUT() -> (MapViewModel, MapModelSpy) {
        let model = MapModelSpy()
        let sut = MapViewModel(model, coordinator: CoordinatorSpy())
        
        return (sut, model)
    }
}

extension MapViewModelTests {
    class MapModelSpy: PMapModel {
        var currentRadius: Int = 5
        var tweets: PublishSubject<[Tweet]> = .init()
        var accumulatableTweets: PublishSubject<[Tweet]> = .init()
        var location: PublishSubject<CLLocation> = .init()
        var presentableError: PublishSubject<Error> = .init()
        var currentId: Int = 0
        var startIsCalled = false
        
        func start() {
            startIsCalled = true
        }
        
        func fetchAfter(id: String) {}
        
        func send(tweets: [Tweet]) {
            accumulatableTweets.onNext(tweets)
        }
    }
    
    class CoordinatorSpy: PCoordinator {
        var isLoggedIn: Bool = false

        func didSelect(_ tweetId: String) {}
        func didSelect(_ tweet: Tweet) {}
        func didTapSearch() {}
        func didTapLogout(completion: @escaping (Bool) -> Void) {}
        func didTapLogin(completion: @escaping (Bool) -> Void) {}
        func handleSuccess(message: String) {}
        func handle(error: Error?) {}
        func start() {}
        func finish() {}
        func coordinatorIsDone(_ child: BaseCoordinatorClass) {}
        func addChild(_ child: BaseCoordinatorClass) {}
    }
}

extension Tweet {
    static func anyTweet(with id: Int) -> Tweet {
        let stringId = "\(id)"
        let author = Author(name: "any name")
        
        return Tweet(id: stringId, text: "anyText", author: author)
    }
}
