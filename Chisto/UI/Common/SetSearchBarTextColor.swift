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

        let placeholder = NSAttributedString(string: self.placeholder ?? "", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): color]))

        searchBarTextField.attributedPlaceholder = placeholder
        searchBarTextField.textColor = color

        break
      }
    }
  }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
