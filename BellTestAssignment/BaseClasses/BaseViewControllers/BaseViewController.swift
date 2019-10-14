//
//  BaseViewController.swift
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
    var isLoggedIn: Bool { get }
    
    func didSelect(_ tweet: TWTRTweet)
    func didSelect(_ tweet: Tweet)
    func didTapSearch()
    func didTapLogout(completion: @escaping (Bool) -> Void)
    func didTapLogin(completion: @escaping (Bool) -> Void)
    
    func handleSuccess(message: String)
    func handle(error: Error?)
}

protocol PViewModel {
    func viewDidLoad()
    func viewWillAppear()
}

extension PViewModel {
    func viewDidLoad() {}
    func viewWillAppear() {}
}

class BaseVC: UIViewController {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vModel.viewWillAppear()
    }
}


protocol RootViewModel: class {
    associatedtype ViewModelType
    
    var vModel: ViewModelType! { get }
}

extension RootViewModel where Self: BaseVC {
    var vModel: ViewModelType {
        return self.vModel as! ViewModelType
    }
}
