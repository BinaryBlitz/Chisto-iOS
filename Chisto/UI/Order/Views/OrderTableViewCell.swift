//
//  OrderTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit


class OrderTableViewCell: UITableViewCell {
  
  @IBOutlet weak var categoryIconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var servicesLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  func configure(viewModel: OrderTableViewCellModelType) {
    categoryIconImageView.image = viewModel.icon
    titleLabel.text = viewModel.itemTitleText
    servicesLabel.attributedText = viewModel.servicesText
    amountLabel.attributedText = viewModel.amountText
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
}
