//
//  ItemInfoTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 21.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class ItemInfoTableViewCell: UITableViewCell {

  @IBOutlet weak var serviceTitleLabel: UILabel!
  @IBOutlet weak var serviceCountLabel: UILabel!
  @IBOutlet weak var serviceDescriptionLabel: UILabel!

  func configure(viewModel: ItemInfoTableViewCellModelType) {
    serviceTitleLabel.text = viewModel.serviceTitle
    serviceDescriptionLabel.text = viewModel.serviceDescription
    serviceCountLabel.text = viewModel.countText
  }

}
