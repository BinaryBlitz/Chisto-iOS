//
//  UIView+AddBorders.swift
//  Chisto
//
//  Created by Алексей on 03.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func addBottomBorder(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.width, height: width)
    self.layer.addSublayer(border)
  }
}
