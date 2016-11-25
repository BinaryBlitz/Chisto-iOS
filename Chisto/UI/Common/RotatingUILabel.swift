//
//  RotatingUIView.swift
//  Chisto
//
//  Created by Алексей on 26.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RotatingUILabel: UILabel {

  override func awakeFromNib() {
    super.awakeFromNib()
    self.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
  }
}
