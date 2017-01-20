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
  var headerLabelFont: UIFont? = nil
  var titleLabelFont: UIFont? = nil
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
      self.headerText = "Сбор вещей"
    case .delivery:
      self.icon = #imageLiteral(resourceName: "iconSmallDelivery")
      self.headerText = "Доставка"
    case .cost:
      self.icon = #imageLiteral(resourceName: "iconSmallCost")
      self.headerText = "Стоимость"
      if !isDisabled {
        titleColor = UIColor.chsJadeGreen
        titleLabelFont = .chsLaundryItemFont
      }
    case .unavaliableCost(let price):
      self.icon = #imageLiteral(resourceName: "iconSmallCost")
      self.headerLabelFont = UIFont.systemFont(ofSize: 10)
      self.headerText = "Стоимость \(price.currencyString)"
      self.headerColor = UIColor.chsCoolGrey
      self.titleColor = UIColor.chsSlateGrey
      self.subTitleColor = UIColor.chsSlateGrey
    }

    self.titleText = titleText
    self.subTitleText = subTitleText

  }
}
