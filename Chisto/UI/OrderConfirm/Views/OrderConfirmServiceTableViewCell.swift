//
//  OrderConfirmServiceTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 02.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import Kingfisher

class OrderConfirmServiceTableViewCell: UITableViewCell {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var iconView: UIImageView!

  func configure(viewModel: OrderConfirmServiceTableViewCellModelType) {
    self.iconView.kf.setImage(with: viewModel.clothesIconUrl) { [weak self] image, _, _, _ in
      guard let image = image?.withRenderingMode(.alwaysTemplate) else { return }
      self?.iconView.image = image
      self?.iconView.tintColor = viewModel.clothesIconColor
    }

    configureHeader(viewModel: viewModel)
    configureDecoration(viewModel: viewModel)
    for service in viewModel.clothesServices {
      let view = OrderConfirmServiceItemView.nibInstance()!
      view.leftLabel.text = service.name
      view.rightLabel.text = service.priceString(laundry: viewModel.laundry)
      stackView.addArrangedSubview(view)
    }
  }

  private func configureHeader(viewModel: OrderConfirmServiceTableViewCellModelType) {
    let headerItemView = OrderConfirmServiceItemView.nibInstance()!
    headerItemView.leftLabel.text = viewModel.clothesTitle
    headerItemView.rightLabel.text = viewModel.clothesPrice
    headerItemView.font = UIFont.chsLabelFont
    headerItemView.textColor = UIColor.black
    stackView.addArrangedSubview(headerItemView)
  }

  private func configureDecoration(viewModel: OrderConfirmServiceTableViewCellModelType) {
    if viewModel.hasDecoration {
      let decorationServiceView = OrderConfirmServiceItemView.nibInstance()!
      decorationServiceView.leftLabel.text = viewModel.decorationTitle
      decorationServiceView.rightLabel.text = viewModel.decorationPrice
      stackView.addArrangedSubview(decorationServiceView)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    for view in stackView.arrangedSubviews {
      stackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }
  }

}
