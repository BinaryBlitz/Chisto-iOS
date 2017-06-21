//
//  HoshiTextField+setValidationState.swift
//  Chisto
//
//  Created by Алексей on 12.05.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import TextFieldEffects

extension HoshiTextField {
  func setValidationState(_ error: Bool = false) {
    borderInactiveColor = error ? .chsWatermelon : .chsCoolGrey
    placeholderColor = error ? .chsWatermelon : .chsSlateGrey
  }
}
