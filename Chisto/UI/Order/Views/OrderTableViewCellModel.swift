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
      servicesAttrString.append(NSAttributedString(string: "Декор", attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))
    }

    if let area = item.area, item.clothesItem.useArea {
      if item.hasDecoration {
        servicesAttrString.append(NSAttributedString(string: " • ", attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
      }
      servicesAttrString.append(NSAttributedString(string: "\(area) м²", attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))

    }

    self.servicesText = servicesAttrString

    let amountText = NSMutableAttributedString()
    amountText.append(NSAttributedString(string: "× ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 24)]))
    amountText.append(NSAttributedString(string: "\(item.amount)"))
    amountText.append(NSAttributedString(string: " шт", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)]))

    self.amountText = amountText

    self.iconUrl = URL(string: item.clothesItem.iconUrl)
  }

}
