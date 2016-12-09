//
//  OrderConfirmServiceTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 02.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

protocol OrderConfirmServiceTableViewCellModelType {
  var clothesIconUrl: URL? { get }
  var clothesIconColor: UIColor { get }
  var clothesTitle: String { get }
  var clothesPrice: String { get }
  var clothesServices: [Treatment] { get }
  var laundry: Laundry { get }
  var hasDecoration: Bool { get }
  var decorationPrice: String { get }
  var decorationTitle: String { get }

}

class OrderConfirmServiceTableViewCellModel: OrderConfirmServiceTableViewCellModelType {

  let clothesIconUrl: URL?
  var clothesIconColor: UIColor
  let clothesTitle: String
  let clothesPrice: String
  let clothesServices: [Treatment]
  let laundry: Laundry
  let hasDecoration: Bool
  let decorationPrice: String = "0 ₽"
  let decorationTitle = "Декор"

  init(orderItem: OrderItem, laundry: Laundry) {
    self.laundry = laundry
    self.hasDecoration = orderItem.hasDecoration
    self.clothesIconUrl = URL(string: orderItem.clothesItem.icon)
    self.clothesIconColor = orderItem.clothesItem.category?.color ?? UIColor.chsSkyBlue
    self.clothesTitle = orderItem.clothesItem.name + " " + orderItem.priceString(laundry: laundry, 1) + " × \(orderItem.amount)"
    self.clothesPrice = orderItem.priceString(laundry: laundry)
    self.clothesServices = orderItem.treatments
  }

}
