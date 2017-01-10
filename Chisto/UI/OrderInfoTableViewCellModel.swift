//
//  OrderInfoTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 20.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

protocol OrderInfoTableViewCellModelType {
  var clothesIconUrl: URL? { get }
  var clothesTitle: String? { get }
  var clothesPrice: String? { get }
  var hasDecoration: Bool { get }
  var decorationPrice: String { get }
  var clothesIconColor: UIColor { get }
  var orderTreatments: [OrderItemTreatment] { get }
}

class OrderInfoTableViewCellModel: OrderInfoTableViewCellModelType {
  
  var clothesIconUrl: URL? = nil
  var clothesIconColor: UIColor = UIColor.chsSkyBlue
  var clothesTitle: String? = nil
  var clothesPrice: String? = nil
  var orderTreatments: [OrderItemTreatment] = []
  var hasDecoration: Bool = false
  var decorationPrice: String = ""
  
  init(orderLineItem: OrderLineItem) {
    guard let item = orderLineItem.item else { return }
    
    self.clothesIconUrl = URL(string: item.icon)
    self.clothesIconColor = item.category?.color ?? UIColor.chsSkyBlue

    self.orderTreatments = orderLineItem.orderItemTreatments

    var clothesTitle = item.name
    if item.useArea {
      clothesTitle +=  " \(orderLineItem.area) м² "
    }
    let price = orderLineItem.price(singleItem: true)
    clothesTitle += " " + price.currencyString + " × \(orderLineItem.quantity)"
    self.clothesTitle = clothesTitle
    
    self.clothesPrice = (price * Double(orderLineItem.quantity)).currencyString

    self.hasDecoration = orderLineItem.hasDecoration
    self.decorationPrice = orderLineItem.decorationPrice.currencyString
  }
}
