//
//  OrderConfirmServiceItemView.swift
//  Chisto
//
//  Created by Алексей on 02.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class OrderConfirmServiceItemView: UIView {

  @IBOutlet weak var leftLabel: UILabel!
  @IBOutlet weak var rightLabel: UILabel!

  var font: UIFont? {
    didSet {
      guard let font = self.font else { return }
      leftLabel.font = font
    }
  }

  var textColor: UIColor? {
    didSet {
      leftLabel.textColor = textColor
      rightLabel.textColor = textColor
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    addBottomBorder(color: UIColor.chsSilver50, width: 0.5)
  }

}
