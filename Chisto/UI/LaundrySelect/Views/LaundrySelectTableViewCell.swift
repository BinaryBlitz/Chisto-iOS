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
import Kingfisher

class LaundrySelectTableViewCell: UITableViewCell {

  @IBOutlet weak var laundryLogoImageView: UIImageView!
  @IBOutlet weak var laundryTitleLabel: UILabel!
  @IBOutlet weak var laundrySubTitleLabel: UILabel!
  @IBOutlet weak var ratingView: FloatRatingView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var laundryTagLabel: RotatingUILabel!
  @IBOutlet weak var logoBackgroundView: UIView!

  var collectionItemView = LaundryItemInfoView.nibInstance()!
  var deliveryItemView = LaundryItemInfoView.nibInstance()!
  var costItemView = LaundryItemInfoView.nibInstance()!

  func configure(viewModel: LaundrySelectTableViewCellModelType) {
    laundryTitleLabel.text = viewModel.laundryTitle
    laundrySubTitleLabel.text = viewModel.laundryDescription
    ratingView.rating = viewModel.rating

    laundryTitleLabel.textColor = viewModel.titleColor
    laundrySubTitleLabel.textColor = viewModel.descriptionColor
    ratingView.fullImage = viewModel.starRatingFullImage
    ratingView.emptyImage = viewModel.starRatingEmptyImage

    laundryLogoImageView.kf.setImage(with: viewModel.logoUrl) { [weak self] image, _, _, _ in
      guard let image = image?.withRenderingMode(.alwaysTemplate), viewModel.isDisabled else { return }
      self?.laundryLogoImageView.image = image
      self?.laundryLogoImageView.tintColor = viewModel.disabledColor
    }

    laundryTagLabel.isHidden = viewModel.tagIsHidden
    laundryTagLabel.backgroundColor = viewModel.tagBgColor
    laundryTagLabel.text = viewModel.tagName

    collectionItemView.configure(viewModel: viewModel.collectionItemViewModel)
    deliveryItemView.configure(viewModel: viewModel.deliveryItemViewModel)
    costItemView.configure(viewModel: viewModel.costItemViewModel)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    stackView.addArrangedSubview(collectionItemView)
    stackView.addArrangedSubview(deliveryItemView)
    stackView.addArrangedSubview(costItemView)
  }

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    saveBackgroundColorsWhileChangingState {
      super.setHighlighted(highlighted, animated: animated)
    }
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    saveBackgroundColorsWhileChangingState {
      super.setSelected(selected, animated: animated)
    }
  }

  func saveBackgroundColorsWhileChangingState(changes: () -> Void) {
    let tagBackColor = laundryTagLabel.backgroundColor
    let logoBackColor = logoBackgroundView.backgroundColor
    changes()
    laundryTagLabel.backgroundColor = tagBackColor
    logoBackgroundView.backgroundColor = logoBackColor
  }

}
