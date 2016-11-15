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
    return treatments.map { $0.price(laundry: laundry) }.reduce(0, +)
  }

  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
}
