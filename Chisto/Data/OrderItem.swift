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
  var treatments: [Treatment]
  var amount: Int
  init (clothesItem: Item, treatments: [Treatment] = [], amount: Int = 1) {
    self.clothesItem = clothesItem
    self.treatments = treatments
    self.amount = amount
  }
  
  func price(laundry: Laundry) -> Int {
    var price = 0
    for treatment in treatments {
      price += treatment.price(laundry: laundry)
    }
    return price
  }
  
  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
}
