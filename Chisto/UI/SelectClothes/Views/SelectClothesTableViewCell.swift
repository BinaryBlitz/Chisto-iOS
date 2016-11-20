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
import Kingfisher
import UIKit

class SelectClothesTableViewCell: UITableViewCell {

  @IBOutlet weak var clothesIconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!

  func configure(viewModel: SelectClothesTableViewCellModelType) {
    clothesIconImageView.kf.setImage(with: viewModel.iconUrl) { [weak self] image, _, _, _ in
      guard let image = image?.withRenderingMode(.alwaysTemplate) else { return }
      self?.clothesIconImageView.image = image
      self?.clothesIconImageView.tintColor = viewModel.iconColor
    }
    titleLabel.text = viewModel.titleText
    descriptionLabel.attributedText = viewModel.subTitletext
  }

}
