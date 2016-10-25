//
//  RoundedButton.swift
//  Chisto
//
//  Created by Алексей on 16.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
extension UIButton {
  @IBInspectable var cornerRadius: CGFloat {
    return layer.cornerRadius
  }
  
  @IBInspectable var borderWidth: CGFloat {
    return layer.borderWidth
  }
  
  @IBInspectable var borderColor: UIColor {
    get {
      return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : UIColor()
    }
    set {
      layer.borderColor = borderColor.cgColor
    }
  }
}
