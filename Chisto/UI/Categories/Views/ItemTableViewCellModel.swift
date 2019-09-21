//
//  CategoryTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 14.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol ItemTableViewCellModelType {
  // Output
  var titleText: String { get }
  var subTitletext: NSAttributedString { get }
  var priceText: String { get }
  var iconUrl: URL? { get }
  var iconColor: UIColor { get }
}

class ItemTableViewCellModel: ItemTableViewCellModelType {
  // Constants
  let dayEndings = ["вещь", "вещи", "вещей"]
  let titleText: String
  var priceText: String
  let subTitletext: NSAttributedString
  let iconUrl: URL?
  let iconColor: UIColor

  init(item: Item) {
    self.titleText = item.name
    self.iconUrl = URL(string: item.iconUrl)
    self.iconColor = item.category?.color ?? UIColor.chsSkyBlue
    self.priceText = ""
    
    self.subTitletext = NSAttributedString(string: item.descriptionText, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.chsSlateGrey]))
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
