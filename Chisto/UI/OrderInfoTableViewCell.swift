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
    self.iconView.kf.setImage(with: viewModel.clothesIconUrl)
    
    let headerItemView = OrderConfirmServiceItemView.nibInstance()!
    headerItemView.leftLabel.text = viewModel.clothesTitle
    headerItemView.rightLabel.text = viewModel.clothesPrice
    headerItemView.font = UIFont.chsLabelFont
    headerItemView.textColor = UIColor.black
    stackView.addArrangedSubview(headerItemView)
    
    
    /* TODO: use real data to display treatments
    for service in viewModel.clothesTreatments {
      let view = OrderConfirmServiceItemView.nibInstance()!
      view.leftLabel.text = service.name
      view.rightLabel.text = service.priceString(laundry: viewModel.laundry)
      stackView.addArrangedSubview(view)
    }
    */
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    for view in stackView.arrangedSubviews {
      stackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }
  }
  
}
