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
    let border = UIView()
    border.backgroundColor = color
    self.addSubview(border)
    border.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    border.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    border.heightAnchor.constraint(equalToConstant: 1).isActive = true
    border.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
  }
}
