//
//  ControlledRatingView.swift
//  Chisto
//
//  Created by Алексей on 17.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import FloatRatingView
import UIKit

class ControlledRatingView: FloatRatingView {
  override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.floatRatingView!(self, didUpdate: rating)
  }
}
