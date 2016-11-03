//
//  OrderConfirmServiceTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 02.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit

class OrderConfirmServiceTableViewCell: UITableViewCell {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var iconView: UIImageView!
  
  
  func configure(viewModel: OrderConfirmServiceTableViewCellModelType) {
    self.iconView.image = viewModel.clothesIcon
    
    let headerItemView = OrderConfirmServiceItemView.nibInstance()!
    headerItemView.leftLabel.text = viewModel.clothesTitle
    headerItemView.font = UIFont.chsLabelFont
    headerItemView.textColor = UIColor.black
    stackView.addArrangedSubview(headerItemView)
    
    for service in viewModel.clothesServices {
      let view = OrderConfirmServiceItemView.nibInstance()!
      view.leftLabel.text = service.name
      stackView.addArrangedSubview(view)
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
