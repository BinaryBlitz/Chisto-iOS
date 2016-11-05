//
//  OrderItem.swift
//  Chisto
//
//  Created by Алексей on 01.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

class OrderItem {
  var id = UUID().uuidString
  var clothesItem: Item
  var services: [Service]
  var amount: Int
  init (clothesItem: Item, services: [Service], amount: Int = 1) {
    self.clothesItem = clothesItem
    self.services = services
    self.amount = amount
  }
  
  func price(laundry: Laundry) -> Int {
    var price = 0
    for service in services {
      price += service.price(laundry: laundry)
    }
    return price
  }
  
  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
}
