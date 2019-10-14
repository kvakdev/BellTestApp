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
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var searchTypes: [SearchType] = [.keyword, .hashtag]
    private var currentType: SearchType {
        return searchTypes[segmentedControl.selectedSegmentIndex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTypes.enumerated().forEach {
            segmentedControl.setTitle($0.element.rawValue, forSegmentAt: $0.offset)
        }
        segmentedControl.addTarget(self, action: #selector(handleValueChanged(_:)), for: .valueChanged)
        
        searchField.addTarget(self, action: #selector(queryDidChange), for: .editingChanged)
        searchField.layer.cornerRadius = 8
        searchField.layer.masksToBounds = true
        
        let dataSource = viewModel.dataSource
        dataSource.setup(tableView: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        loader.hidesWhenStopped = true
        loader.stopAnimating()
        
        viewModel.isLoaderVisible.subscribe(onNext: { [unowned self] visible in
            if visible {
                self.loader.startAnimating()
            } else {
                self.loader.stopAnimating()
            }
        }).disposed(by: disposeBag)
    }
    
    @objc func handleValueChanged(_ sender: UISegmentedControl) {
        queryDidChange()
    }
    
    @objc private func queryDidChange() {
        var query = searchField.text ?? ""
        
        if currentType == .hashtag && !query.trimmed.isEmpty {
            query = "#".appending(query)
        }
        
        viewModel.didChangeQuery(query)
    }
}
