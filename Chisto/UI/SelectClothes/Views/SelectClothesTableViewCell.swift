//
//  SelectClothesTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 18.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit


import Foundation
import RxSwift
import UIKit

class SelectClothesTableViewCell: UITableViewCell {
  
  @IBOutlet weak var clothesIconImageView: UIImageView!
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  
  func configure(viewModel: SelectClothesTableViewCellModelType) {
    clothesIconImageView.image = viewModel.icon
    titleLabel.text = viewModel.titleText
    descriptionLabel.attributedText = viewModel.subTitletext
  }
  
}