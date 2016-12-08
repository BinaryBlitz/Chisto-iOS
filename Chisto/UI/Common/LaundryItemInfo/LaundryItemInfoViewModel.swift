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
}

class LaundryItemInfoViewModel {
  let icon: UIImage
  let headerText: String
  let titleText: String
  let subTitleText: String?
  let type: LaundryItemInfoType

  init(type: LaundryItemInfoType, titleText: String, subTitleText: String? = nil) {
    self.type = type

    switch type {
    case .collection:
      self.icon = #imageLiteral(resourceName: "iconSmallCourier")
      self.headerText = "Курьер"
    case .delivery:
      self.icon = #imageLiteral(resourceName: "iconSmallDelivery")
      self.headerText = "Доставка"
    case .cost:
      self.icon = #imageLiteral(resourceName: "iconSmallCost")
      self.headerText = "Стоимость"
    }

    self.titleText = titleText
    self.subTitleText = subTitleText

  }
}
