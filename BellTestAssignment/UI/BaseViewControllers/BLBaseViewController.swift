//
//  BLBaseViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import RxSwift
import TwitterKit

protocol BaseCoordinator {
    func start()
    func finish()
    func coordinatorIsDone(_ child: BaseCoordinatorClass)
    func addChild(_ child: BaseCoordinatorClass)
}

protocol PCoordinator: BaseCoordinator {
    func didSelect(_ tweet: TWTRTweet)
    func didSelect(_ tweet: BLTweet)
    func didTapSearch()
    
    func handleSuccess(message: String)
    func handle(error: Error?)
}

protocol PViewModel {
    func viewDidLoad()
}

class BLBaseVC: UIViewController {
    var vModel: PViewModel!
    
    let disposeBag = DisposeBag()
    
    func set(vModel: PViewModel) {
        self.vModel = vModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vm = vModel else { fatalError("view model must be set") }
        vm.viewDidLoad()
    }
}


protocol RootViewModel: class {
    associatedtype ViewModelType
    
    var vModel: ViewModelType! { get }
}

extension RootViewModel where Self: BLBaseVC {
    var vModel: ViewModelType {
        return self.vModel as! ViewModelType
    }
}
