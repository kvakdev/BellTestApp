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
