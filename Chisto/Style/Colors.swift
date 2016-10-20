//
//  Colors.swift
//  Chisto
//
//  Created by Алексей on 11.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit

// Sample color palette

// Color palette

extension UIColor {
  
  func lighter(percentage:CGFloat = 0.1) -> UIColor {
    return self.colorWithBrightness(factor: 1 + abs(percentage))
  }
  
  func darker(percentage:CGFloat = 0.1) -> UIColor {
    return self.colorWithBrightness(factor: 1 - abs(percentage))
  }
  
  func colorWithBrightness(factor: CGFloat) -> UIColor {
    var hue : CGFloat = 0
    var saturation : CGFloat = 0
    var brightness : CGFloat = 0
    var alpha : CGFloat = 0
    
    if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
      return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
    } else {
      return self
    }
  }
  
  class var chsSkyBlue: UIColor {
    return UIColor(red: 72.0 / 255.0, green: 194.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
  }
  
  class var chsCoolGrey: UIColor {
    return UIColor(red: 180.0 / 255.0, green: 187.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
  }
  
  class var chsWhite: UIColor {
    return UIColor(white: 247.0 / 255.0, alpha: 1.0)
  }
  
  class var chsSlateGrey: UIColor {
    return UIColor(red: 101.0 / 255.0, green: 108.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
  }
  
  class var chsWhite50: UIColor {
    return UIColor(white: 255.0 / 255.0, alpha: 0.5)
  }
  
  class var chsWhiteTwo: UIColor {
    return UIColor(white: 247.0 / 255.0, alpha: 1.0)
  }
  
  class var chsSilver: UIColor {
    return UIColor(red: 193.0 / 255.0, green: 199.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
  }
  
  class var chsRosePink: UIColor {
    return UIColor(red: 243.0 / 255.0, green: 125.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
  }
  
  class var chsSilver50: UIColor {
    return UIColor(red: 193.0 / 255.0, green: 199.0 / 255.0, blue: 205.0 / 255.0, alpha: 0.5)
  }
  
}
