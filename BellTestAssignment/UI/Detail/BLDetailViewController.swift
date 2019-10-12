//
//  BLDetailViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

class BLDetailViewController: BLBaseVC {
    private var viewModel: PDetailViewModel {
        return self.vModel as! PDetailViewModel
    }
    
    @IBOutlet private weak var _profileImageView: UIImageView!
    @IBOutlet private weak var _handleLabel: UILabel!
    @IBOutlet private weak var _textLabel: UILabel!
    @IBOutlet private weak var _timestampLabel: UILabel!
    @IBOutlet private weak var _nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.tweet.subscribe(onNext: { [weak self] tweet in
            self?._handleLabel.text = tweet.author.screenName
            self?._textLabel.text = tweet.text
            self?._profileImageView.load(urlString: tweet.author.profileImageLargeURL)
        }).disposed(by: disposeBag)
        
        self.viewModel.timestamp.subscribe(onNext: { [weak self] timestamp in
            self?._timestampLabel.text = timestamp
        }).disposed(by: disposeBag)
    }

}
