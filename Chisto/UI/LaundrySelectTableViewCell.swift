//
//  LaundrySelectTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 26.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import FloatRatingView

class LaundrySelectTableViewCell: UITableViewCell {
  @IBOutlet weak var laundryLogoImageView: UIImageView!
  @IBOutlet weak var laundryTitleLabel: UILabel!
  @IBOutlet weak var laundrySubTitleLabel: UILabel!
  @IBOutlet weak var ratingView: FloatRatingView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var laundryTagLabel: RotatingUILabel!
  
  func configure(viewModel: LaundrySelectTableViewCellModelType) {
    laundryTitleLabel.text = viewModel.laundryTitle
    laundrySubTitleLabel.text = viewModel.laundryDescription
    ratingView.rating = viewModel.rating
    laundryTagLabel.backgroundColor = viewModel.tagBgColor
    laundryTagLabel.text = viewModel.tagName
    
    for viewModel in viewModel.laundryDescriptionViewModels {
      let laundryItemView = LaundryItemInfoView.nibInstance()!
      laundryItemView.configure(viewModel: viewModel)
      
      laundryItemView.backgroundColor = UIColor.chsWhiteTwo
      stackView.addArrangedSubview(laundryItemView)
    }
  }
}
