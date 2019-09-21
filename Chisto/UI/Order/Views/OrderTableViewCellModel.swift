//
//  OrderTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import Kingfisher

protocol OrderTableViewCellModelType {
  // Output
  var itemTitleText: String { get }
  var servicesText: NSAttributedString { get }
  var iconUrl: URL? { get }
  var iconColor: UIColor { get }
  var amountText: NSAttributedString { get }
}

class OrderTableViewCellModel: OrderTableViewCellModelType {
  // Constants
  let itemTitleText: String
  let servicesText: NSAttributedString
  let iconUrl: URL?
  let iconColor: UIColor
  let amountText: NSAttributedString

  init(item: OrderItem) {
    self.itemTitleText = item.clothesItem.name
    self.iconColor = item.clothesItem.category?.color ?? UIColor.chsSkyBlue

    let servicesAttrString = NSMutableAttributedString()

    if item.hasDecoration {
      servicesAttrString.append(NSAttributedString(string: "Декор", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.chsSlateGrey])))
    }

    if let area = item.area, item.clothesItem.useArea {
      if item.hasDecoration {
        servicesAttrString.append(NSAttributedString(string: " • ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.chsSilver])))
      }
      servicesAttrString.append(NSAttributedString(string: "\(area) м²", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.chsSlateGrey])))

    }

    self.servicesText = servicesAttrString

    let amountText = NSMutableAttributedString()
    amountText.append(NSAttributedString(string: "× ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 24)])))
    amountText.append(NSAttributedString(string: "\(item.amount)"))
    amountText.append(NSAttributedString(string: " шт", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 18)])))

    self.amountText = amountText

    self.iconUrl = URL(string: item.clothesItem.iconUrl)
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
