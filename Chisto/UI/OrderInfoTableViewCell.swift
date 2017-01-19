//
//  OrderInfoTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 20.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class OrderInfoTableViewCell: UITableViewCell {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var iconView: UIImageView!
  
  func configure(viewModel: OrderInfoTableViewCellModelType) {
    self.iconView.kf.setImage(with: viewModel.clothesIconUrl)  { [weak self] image, _, _, _ in
      guard let image = image?.withRenderingMode(.alwaysTemplate) else { return }
      self?.iconView.image = image
      self?.iconView.tintColor = viewModel.clothesIconColor
    }
    
    let headerItemView = OrderConfirmServiceItemView.nibInstance()!
    headerItemView.leftLabel.text = viewModel.clothesTitle
    headerItemView.rightLabel.text = viewModel.clothesPrice
    headerItemView.font = UIFont.chsLabelFont
    headerItemView.textColor = UIColor.black
    stackView.addArrangedSubview(headerItemView)

    configureDecoration(viewModel: viewModel)
    
    for orderTreatment in viewModel.orderTreatments {
      let view = OrderConfirmServiceItemView.nibInstance()!
      view.leftLabel.text = orderTreatment.treatment?.name
      view.rightLabel.text = orderTreatment.price.currencyString
      stackView.addArrangedSubview(view)
    }
  }

  private func configureDecoration(viewModel: OrderInfoTableViewCellModelType) {
    if viewModel.hasDecoration {
      let decorationServiceView = OrderConfirmServiceItemView.nibInstance()!
      decorationServiceView.leftLabel.text = "Декор"
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
