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
  @IBOutlet weak var laundryTagLabel: RotatingUILabel!
  @IBOutlet weak var logoBackgroundView: UIView!

  // Stack view
  @IBOutlet weak var priceStackView: UIStackView!
  @IBOutlet var minimumPriceLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet weak var priceLabelTrailingConstraint: NSLayoutConstraint!

  func configure(viewModel: LaundrySelectTableViewCellModelType) {
    laundryTitleLabel.text = viewModel.laundryTitle
    laundrySubTitleLabel.text = viewModel.laundryDescription
    ratingView.rating = Double(viewModel.rating)

    laundryTitleLabel.textColor = viewModel.titleColor
    laundrySubTitleLabel.textColor = viewModel.descriptionColor
    ratingView.fullImage = viewModel.starRatingFullImage
    ratingView.emptyImage = viewModel.starRatingEmptyImage

    laundryLogoImageView.kf.setImage(with: viewModel.logoUrl) { [weak self] image, _, _, _ in
      guard let image = image?.withRenderingMode(.alwaysTemplate), viewModel.isDisabled else { return }
      self?.laundryLogoImageView.image = image
      self?.laundryLogoImageView.tintColor = viewModel.disabledColor
    }
    for view in priceStackView.arrangedSubviews {
      priceStackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }

    if viewModel.isDisabled {
      priceStackView.addArrangedSubview(minimumPriceLabel)
      minimumPriceLabel.font = UIFont.systemFont(ofSize: 11)
      priceLabel.text = viewModel.minimumOrderPrice
      priceLabel.font = UIFont.systemFont(ofSize: 15)
      priceLabel.textColor = UIColor.chsSlateGrey
    } else {
      priceLabel.text = viewModel.price
      priceLabel.font = UIFont.systemFont(ofSize: 20)
      priceLabel.textColor = UIColor.chsJadeGreen
    }
    priceStackView.addArrangedSubview(priceLabel)
    laundryTagLabel.isHidden = viewModel.tagIsHidden
    laundryTagLabel.backgroundColor = viewModel.tagBgColor
    laundryTagLabel.text = viewModel.tagName
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

  override func awakeFromNib() {
    super.awakeFromNib()
    clearPriceStackView()
  }

  func saveBackgroundColorsWhileChangingState(changes: () -> Void) {
    let tagBackColor = laundryTagLabel.backgroundColor
    let logoBackColor = logoBackgroundView.backgroundColor
    changes()
    laundryTagLabel.backgroundColor = tagBackColor
    logoBackgroundView.backgroundColor = logoBackColor
  }

  func clearPriceStackView() {
    for view in priceStackView.arrangedSubviews {
      priceStackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }

  }

  override func prepareForReuse() {
    super.prepareForReuse()
    clearPriceStackView()
  }

}
