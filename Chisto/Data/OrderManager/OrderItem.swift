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
  var hasDecoration: Bool
  var treatments: [Treatment]
  var amount: Int

  init (clothesItem: Item, treatments: [Treatment] = [], amount: Int = 1, hasDecoration: Bool = false) {
    self.clothesItem = clothesItem
    self.treatments = treatments
    self.amount = amount
    self.hasDecoration = hasDecoration
  }

  func price(laundry: Laundry, _ count: Int? = nil) -> Int {
    let amount = count ?? self.amount
    return treatments.map { $0.price(laundry: laundry) }.reduce(0, +) * amount
  }

  func priceString(laundry: Laundry, _ count: Int? = nil) -> String {
    let price = self.price(laundry: laundry, count)
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
}
