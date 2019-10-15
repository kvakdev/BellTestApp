//
//  SearchViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

public class SearchViewController: BaseViewController {
    private enum SearchType: String {
        case keyword = "Keyword"
        case hashtag = "Hashtag"
    }
    private var viewModel: SearchViewModelProtocol {
        return self.vModel as! SearchViewModelProtocol
    }
    
    @IBOutlet private weak var searchField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    private var searchTypes: [SearchType] = [.keyword, .hashtag]
    private var currentType: SearchType {
        return searchTypes[segmentedControl.selectedSegmentIndex]
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupSearchField()
        setupLoader()
    }

    private func setupLoader() {
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

    private func setupSearchField() {
        searchTypes.enumerated().forEach {
            segmentedControl.setTitle($0.element.rawValue, forSegmentAt: $0.offset)
        }

        searchField.layer.cornerRadius = 8
        searchField.layer.masksToBounds = true
    }

    private func setupDataSource() {
        let dataSource = viewModel.dataSource
        dataSource.setup(tableView: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    @IBAction func handleValueChanged(_ sender: UISegmentedControl) {
        queryDidChange()
    }
    
    @IBAction private func queryDidChange() {
        var query = searchField.text ?? ""
        
        if currentType == .hashtag && !query.trimmed.isEmpty {
            query = "#".appending(query)
        }
        
        viewModel.didChangeQuery(query)
    }
}
