//
//  OrderTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class OrderTableViewCell: UITableViewCell {

  @IBOutlet weak var categoryIconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var servicesLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!

  func configure(viewModel: OrderTableViewCellModelType) {
    categoryIconImageView.kf.setImage(with: viewModel.iconUrl) { [weak self] image, _, _, _ in
      guard let image = image?.withRenderingMode(.alwaysTemplate) else { return }
      self?.categoryIconImageView.image = image
      self?.categoryIconImageView.tintColor = viewModel.iconColor
    }
    titleLabel.text = viewModel.itemTitleText
    servicesLabel.attributedText = viewModel.servicesText
    amountLabel.attributedText = viewModel.amountText
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

}
