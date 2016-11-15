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

    if viewModel.type == .cost {
      titleLabel.font = UIFont.chsLaundryItemFont
      titleLabel.textColor = UIColor.chsJadeGreen
    }

  }

}
