//
//  BLSearchViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

class BLSearchViewController: BLBaseVC {
    private var viewModel: PSearchViewModel {
        return self.vModel as! PSearchViewModel
    }
    
    @IBOutlet weak var _searchField: UITextField!
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var _loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _searchField.addTarget(self, action: #selector(queryDidChange), for: .editingChanged)
        
        let dataSource = viewModel.dataSource
        dataSource.setup(tableView: _tableView)
        _tableView.dataSource = dataSource
        _tableView.delegate = dataSource
        
        _loader.hidesWhenStopped = true
        _loader.stopAnimating()
        
        viewModel.isLoaderVisible.subscribe(onNext: { [unowned self] visible in
            if visible {
                self._loader.startAnimating()
            } else {
                self._loader.stopAnimating()
            }
        }).disposed(by: disposeBag)
    }
    
    @objc private func queryDidChange() {
        viewModel.didChangeQuery(_searchField.text ?? "")
    }
}
