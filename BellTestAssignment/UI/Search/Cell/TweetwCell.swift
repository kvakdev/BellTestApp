//
//  TweetwCell.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

class TweetwCell: UITableViewCell {
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _textLabel: UILabel!
    
    func set(viewModel: Tweet) {
        _titleLabel.text = viewModel.author.screenName
        _textLabel.text = viewModel.text
    }
}
