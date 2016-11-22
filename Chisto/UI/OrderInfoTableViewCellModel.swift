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
  
  let clothesIconUrl: URL?
  var clothesIconColor: UIColor
  let clothesTitle: String?
  let clothesPrice: String?
  var orderLineItems: [OrderLineItem]
  
  init(item: Item, orderLineItems: [OrderLineItem]) {
    self.clothesIconUrl = URL(string: item.icon)
    self.clothesIconColor = item.category?.color ?? UIColor.chsSkyBlue
    
    let quantity = orderLineItems.first?.quantity ?? 0
    self.clothesTitle = item.name + " " + item.priceString(lineItems: orderLineItems, quantity: 1) + " × \(quantity)"
    self.clothesPrice = item.priceString(lineItems: orderLineItems)
    self.orderLineItems = orderLineItems
  }
  
}
