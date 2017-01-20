//
//  LaundryItemInfoView.swift
//  Chisto
//
//  Created by Алексей on 24.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit

class LaundryItemInfoView: UIView {

  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subTitleLabel: UILabel!

  func configure(viewModel: LaundryItemInfoViewModel) {
    iconImageView.image = viewModel.icon
    headerLabel.text = viewModel.headerText
    titleLabel.text = viewModel.titleText
    subTitleLabel.text = viewModel.subTitleText

    headerLabel.textColor = viewModel.headerColor
    titleLabel.textColor = viewModel.titleColor
    subTitleLabel.textColor = viewModel.subTitleColor

    if let headerFont = viewModel.headerLabelFont {
      headerLabel.font = headerFont
    }

    if let titleFont = viewModel.titleLabelFont {
      titleLabel.font = titleFont
    }
  }

}
