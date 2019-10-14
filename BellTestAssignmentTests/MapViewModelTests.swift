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

        let firstPack = Tweet.tweets(with: (1...11))
        let secondPack = Tweet.tweets(with: (12...lastId))
        
        modelSpy.sendAcc(tweets: tweetsSent)
        tweetsSent.append(contentsOf: firstPack)
        modelSpy.sendAcc(tweets: firstPack)
        tweetsSent.append(contentsOf: secondPack)
        modelSpy.sendAcc(tweets: secondPack)
        
        wait(for: [exp], timeout: 5)
    }
    
    func test_accumulator_publishesCorrectAmount() {
        //given
        let (sut, modelSpy) = makeSUT()
        let exp = expectation(description: "waiting for load to complete")
        let capacity = sut.tweetCapacity
        let maxCount = capacity * 2
        
        sut.tweets.subscribe(onNext: { tweets in
            //then
            XCTAssertTrue(tweets.count <= capacity)
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        //when
        sut.viewDidLoad()
        modelSpy.sendAcc(tweets: Tweet.withCount(maxCount))
        wait(for: [exp], timeout: 5)
    }
    
    func test_timer_tiggersLoadWithIncrementedIds() {
        //given
        let (sut, modelSpy) = makeSUT()
        sut.timerInterval = 0.5
        
        let exp = expectation(description: "waiting for load to complete")
        var lastTweet: Tweet = Tweet.anyTweet(with: 0)
        var clicks = 0
        sut.tweets.subscribe(onNext: { tweets in
            let oldLastId = Int(lastTweet.id)!
            let newLastId = Int(tweets.last!.id)!
            lastTweet = tweets.last!
            clicks += 1
            //then
            debugPrint("Click \(clicks) lastId = \(oldLastId) newFirst = \(newLastId)")
            XCTAssertTrue(oldLastId < newLastId)
            if clicks >= 5 { exp.fulfill() }
        }).disposed(by: disposeBag)
        
        //when
        sut.viewDidLoad()
        modelSpy.sendRegular(tweets: [Tweet.anyTweet(with: 1)])
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
        
        func fetchAfter(id: String) {
            guard let intValue = Int(id) else { return }
            
            let start = intValue + 1
            let finish = start + 10
            
            let tweets = Tweet.tweets(with: (start...finish))
            self.accumulatableTweets.onNext(tweets)
        }
        
        func sendAcc(tweets: [Tweet]) {
            accumulatableTweets.onNext(tweets)
        }
        
        func sendRegular(tweets: [Tweet]) {
            self.tweets.onNext(tweets)
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

private extension Tweet {
    static func anyTweet(with id: Int) -> Tweet {
        let stringId = "\(id)"
        let author = Author(name: "any name")
        
        return Tweet(id: stringId, text: "anyText", author: author)
    }
    
    static func tweets(with ids: ClosedRange<Int>) -> [Tweet] {
        return ids.compactMap { anyTweet(with: $0) }
    }
    
    static func withCount(_ count: Int) -> [Tweet] {
        return tweets(with: 0...count)
    }
}
