//
//  CategoryTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import RxSwift
import Kingfisher
import UIKit

class CategoryTableViewCell: UITableViewCell {

  @IBOutlet weak var categoryIconImageView: UIImageView!

  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var descriptionLabel: UILabel!

  func configure(viewModel: CategoryTableViewCellModelType) {
    
    categoryIconImageView.kf.setImage(with: viewModel.iconUrl) { [weak self] image, _, _, _ in
      guard let image = image?.withRenderingMode(.alwaysTemplate) else { return }
      self?.categoryIconImageView.image = image
      self?.categoryIconImageView.tintColor = viewModel.iconColor
    }
    titleLabel.text = viewModel.titleText
    descriptionLabel.attributedText = viewModel.subTitletext
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = UIColor.chsWhite
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
