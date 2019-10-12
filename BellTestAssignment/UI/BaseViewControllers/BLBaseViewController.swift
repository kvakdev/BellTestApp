//
//  BLBaseViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import RxSwift

protocol PCoordinator {
    func didSelect(_ tweet: BLTweet)
    func handle(error: Error)
    func start()
}

protocol PViewModel {
    func viewDidLoad()
}

class BLBaseVC: UIViewController, RootViewModel {
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
//
//extension RootViewModel where Self: BLBaseVC {
//
//    var vModel: ViewModelType {
//        return self.vModel
//    }
//
//}
