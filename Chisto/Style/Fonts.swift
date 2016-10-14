//
//  Fonts.swift
//  Chisto
//
//  Created by Алексей on 14.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit

// Sample text styles

extension UIFont {
  class var descriptionFont: UIFont? {
    return UIFont(name: ".AppleSystemUIFont", size: 18.0)
  }
  
  class func chsDescriptionFont() -> UIFont? {
    return UIFont(name: ".AppleSystemUIFont", size: 18.0)
  }
  
  class func chsLabelFont() -> UIFont? {
    return UIFont(name: ".AppleSystemUIFont", size: 16.0)
  }
  
  class func chsOnBoardStageFont() -> UIFont? {
    return UIFont(name: ".AppleSystemUIFont", size: 12.0)
  }
}
