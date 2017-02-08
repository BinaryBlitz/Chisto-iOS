//
//  LaundryItemInfoViewModel.swift
//  Chisto
//
//  Created by Алексей on 25.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

enum LaundryItemInfoType {
  case collection
  case delivery
  case cost
  case unavaliableCost(price: Double)
}

class LaundryItemInfoViewModel {
  var titleColor: UIColor = .black
  var subTitleColor: UIColor = .black
  var headerColor: UIColor = .chsSkyBlue
  var headerLabelFont: UIFont? = .preferredFont(forTextStyle: .caption1)
  var titleLabelFont: UIFont? = .preferredFont(forTextStyle: .caption2)
  let icon: UIImage
  let headerText: String
  let titleText: String
  let isDisabled: Bool
  let subTitleText: String?
  let type: LaundryItemInfoType

  init(type: LaundryItemInfoType, titleText: String, subTitleText: String? = nil, isDisabled: Bool = false) {
    self.type = type
    self.isDisabled = isDisabled

    if isDisabled {
      titleColor = .chsCoolGrey
      subTitleColor = .chsCoolGrey
      headerColor = .chsCoolGrey
    }

    switch type {
    case .collection:
      self.icon = #imageLiteral(resourceName: "iconSmallCourier")
      self.headerText = NSLocalizedString("itemsCollection", comment: "Order items collection")
    case .delivery:
      self.icon = #imageLiteral(resourceName: "iconSmallDelivery")
      self.headerText = NSLocalizedString("delivery", comment: "Order items delivery")
    case .cost:
      self.icon = #imageLiteral(resourceName: "iconSmallCost")
      self.headerText = NSLocalizedString("cost", comment: "Order cost")
      if !isDisabled {
        titleColor = UIColor.chsJadeGreen
        titleLabelFont = UIFont.preferredFont(forTextStyle: .callout)
      }
    case .unavaliableCost(let price):
      self.icon = #imageLiteral(resourceName: "iconSmallCost")
      self.headerLabelFont = UIFont.preferredFont(forTextStyle: .caption2)
      self.headerText = NSLocalizedString("cost", comment: "Order cost") + " " + String(price.currencyString)
      self.headerColor = UIColor.chsCoolGrey
      self.titleColor = UIColor.chsSlateGrey
      self.subTitleColor = UIColor.chsSlateGrey
    }

    self.titleText = titleText
    self.subTitleText = subTitleText

  }
}
