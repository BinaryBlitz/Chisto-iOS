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
  var decorationPrice: String = "0"
  let decorationTitle = NSLocalizedString("decoration", comment: "Decoration service")

  init(orderItem: OrderItem, laundry: Laundry) {
    self.laundry = laundry
    self.clothesIconUrl = URL(string: orderItem.clothesItem.iconUrl)
    self.clothesIconColor = orderItem.clothesItem.category?.color ?? UIColor.chsSkyBlue
    var clothesTitle = orderItem.clothesItem.name
    if let area = orderItem.area {
      clothesTitle += " \(area) м² "
    }
    clothesTitle += " " + orderItem.price(laundry: laundry, 1).currencyString + " × \(orderItem.amount)"
    self.clothesTitle = clothesTitle
    self.clothesPrice = orderItem.price(laundry: laundry).currencyString
    self.clothesServices = orderItem.treatments

    self.hasDecoration = orderItem.hasDecoration
    self.decorationPrice = orderItem.decorationPrice(laundry: laundry).currencyString
  }

}
