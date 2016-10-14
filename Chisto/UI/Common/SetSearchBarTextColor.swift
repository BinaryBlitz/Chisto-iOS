//
//  SetSearchBarTextColor.swift
//  Chisto
//
//  Created by Алексей on 14.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//  The most straightforward way to change search bar text field without accessing private API
//

import Foundation
import UIKit

extension UISearchBar {
  func setTextColor(color: UIColor) {
    
    for subView in self.subviews
    {
      for secondLevelSubview in subView.subviews
      {
        if (secondLevelSubview.isKind(of: UITextField.self))
        {
          if let searchBarTextField:UITextField = secondLevelSubview as? UITextField
          {
            searchBarTextField.textColor = color
            searchBarTextField.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSForegroundColorAttributeName: color])
            break
          }
        }
      }
    }
  }
}
