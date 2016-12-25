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
  var clothesIconColor: UIColor { get }
  var orderLineItems: [OrderLineItem] { get }
}

class OrderInfoTableViewCellModel: OrderInfoTableViewCellModelType {
  
  var clothesIconUrl: URL? = nil
  var clothesIconColor: UIColor = UIColor.chsSkyBlue
  var clothesTitle: String? = nil
  var clothesPrice: String? = nil
  var orderLineItems: [OrderLineItem] = []
  
  init(itemInfo: LineItemInfo, orderLineItems: [OrderLineItem]) {
    guard let item = itemInfo.item else { return }
    
    self.clothesIconUrl = URL(string: item.icon)
    self.clothesIconColor = item.category?.color ?? UIColor.chsSkyBlue
    
    let quantity = itemInfo.quantity
    self.clothesTitle = item.name + " " + self.priceString(lineItems: orderLineItems, singleItem: true) + " × \(quantity)"
    self.clothesPrice = self.priceString(lineItems: orderLineItems)
    self.orderLineItems = orderLineItems
  }
  
  func price(orderLineItems: [OrderLineItem], singleItem: Bool = false) -> Double {
    return orderLineItems.map { singleItem ? $0.itemPrice : $0.totalPrice }.reduce(0, +)
  }

  func priceString(lineItems: [OrderLineItem], singleItem: Bool = false) -> String {
    let price = self.price(orderLineItems: lineItems, singleItem: singleItem)
    return price == 0 ? "Бесплатно" : price.currencyString
  }
  
}
