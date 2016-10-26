//
//  RotatingUIView.swift
//  Chisto
//
//  Created by Алексей on 26.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class RotatingUILabel: UILabel {
  @IBInspectable var rotation: Double = 0 {
    didSet {
      rotateView(rotation: rotation)
    }
  }
  
  func rotateView(rotation: Double)  {
    self.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2 + rotation))
  }
}
