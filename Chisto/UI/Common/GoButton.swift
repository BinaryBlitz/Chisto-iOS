//
//  GoButton.swift
//  Chisto
//
//  Created by Алексей on 15.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit

@IBDesignable class GoButton: UIButton {
  let animationDuration = 0.2
  
  @IBInspectable var defaultBackgroundColor: UIColor = UIColor.chsSkyBlue
  
  @IBInspectable var defaultDisabledColor: UIColor = UIColor.chsCoolGrey
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        backgroundColor = defaultBackgroundColor
      } else {
        backgroundColor = defaultDisabledColor
      }
    }
  }
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        self.backgroundColor = self.defaultBackgroundColor.darker()
      } else {
        UIView.animate(withDuration: animationDuration, animations: {
          self.backgroundColor = self.defaultBackgroundColor
        })
      }
    }
  }

}
