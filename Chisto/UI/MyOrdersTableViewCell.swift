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
  @IBOutlet weak var orderDateLabel: UILabel!
  @IBOutlet weak var orderStatusImageView: UIImageView!
  
  func configure(viewModel: MyOrdersTableViewCellModelType) {
    orderNumberLabel.text = viewModel.orderNumberTitle
    orderDateLabel.text = viewModel.dateTitle
    orderStatusImageView.image = viewModel.icon
  }
}
