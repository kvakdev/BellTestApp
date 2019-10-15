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

public class BaseViewController: UIViewController {
    var vModel: ViewModelProtocol!
    
    let disposeBag = DisposeBag()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vm = vModel else { fatalError("view model must be set") }
        vm.viewDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vModel.viewWillAppear()
    }

    func set(vModel: ViewModelProtocol) {
        self.vModel = vModel
    }
}


public protocol RootViewModel: class {
    associatedtype ViewModelType
    var vModel: ViewModelType! { get }
}

public extension RootViewModel where Self: BaseViewController {
    var vModel: ViewModelType {
        return self.vModel as! ViewModelType
    }
}
