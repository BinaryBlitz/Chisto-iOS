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
    for subview in self.subviews {
      for secondLevelSubview in subview.subviews {
        guard secondLevelSubview.isKind(of: UITextField.self) else { continue }
        guard let searchBarTextField = secondLevelSubview as? UITextField else { continue }

        let placeholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSForegroundColorAttributeName: color])

        searchBarTextField.attributedPlaceholder = placeholder
        searchBarTextField.textColor = color
        
        break
      }
    }
  }

}
