//
//  MyOrdersTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class MyOrdersTableViewCell: UITableViewCell {
  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var orderDateStatusLabel: UILabel!
  @IBOutlet weak var orderStatusImageView: UIImageView!
  @IBOutlet weak var priceLabel: UILabel!

  func configure(viewModel: MyOrdersTableViewCellModelType) {
    orderNumberLabel.text = viewModel.orderNumberTitle
    orderDateStatusLabel.text = viewModel.dateStatusTitle
    orderStatusImageView.image = viewModel.icon
    priceLabel.text = viewModel.priceTitle
  }
}
