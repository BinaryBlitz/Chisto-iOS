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

struct CommonSizes {
    static var footerSize = 50.00
}

extension UIColor {
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
    
    class var chsRosePink: UIColor {
        return UIColor(red: 243.0 / 255.0, green: 125.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
    }
    
    class var chsWhiteTwo: UIColor {
        return UIColor(white: 255.0 / 255.0, alpha: 1.0)
    }

}

// Sample text styles

extension UIFont {
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
