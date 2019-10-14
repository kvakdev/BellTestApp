//
//  SearchViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

class SearchViewController: BaseVC {
    private enum SearchType: String {
        case keyword = "Keyword"
        case hashtag = "Hashtag"
    }
    private var viewModel: PSearchViewModel {
        return self.vModel as! PSearchViewModel
    }
    
    @IBOutlet weak var _searchField: UITextField!
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var _loader: UIActivityIndicatorView!
    @IBOutlet weak var _segmentedControl: UISegmentedControl!
    
    private var _searchTypes: [SearchType] = [.keyword, .hashtag]
    private var currentType: SearchType {
        return _searchTypes[_segmentedControl.selectedSegmentIndex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _searchTypes.enumerated().forEach {
            _segmentedControl.setTitle($0.element.rawValue, forSegmentAt: $0.offset)
        }
        _segmentedControl.addTarget(self, action: #selector(handleValueChanged(_:)), for: .valueChanged)
        
        _searchField.addTarget(self, action: #selector(queryDidChange), for: .editingChanged)
        _searchField.layer.cornerRadius = 8
        _searchField.layer.masksToBounds = true
        
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
    
    @objc func handleValueChanged(_ sender: UISegmentedControl) {
        queryDidChange()
    }
    
    @objc private func queryDidChange() {
        var query = _searchField.text ?? ""
        
        if currentType == .hashtag && !query.trimmed.isEmpty {
            query = "#".appending(query)
        }
        
        viewModel.didChangeQuery(query)
    }
}
