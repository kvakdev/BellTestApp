//
//  TweetwCell.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

class TweetwCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    func set(viewModel: Tweet) {
       titleLabel.text = viewModel.author.screenName
       detailsLabel.text = viewModel.text
    }
}
