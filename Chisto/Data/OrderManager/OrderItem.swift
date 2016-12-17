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
  var size: (width: Int, length: Int)? = nil
  var amount: Int

  let squareCentimetersInMeter: Double = 10000

  init (clothesItem: Item, treatments: [Treatment] = [], amount: Int = 1, hasDecoration: Bool = false) {
    self.clothesItem = clothesItem
    self.treatments = treatments
    self.amount = amount
    self.hasDecoration = hasDecoration
  }

  var area: Int {
    guard let size = size else { return 0 }
    let area = ceil(Double(size.length * size.width) / squareCentimetersInMeter)
    return Int(area)
  }
  
  func price(laundry: Laundry, _ count: Int? = nil) -> Double {
    let amount = count ?? self.amount

    let price = treatments.map { $0.price(laundry: laundry, hasDecoration: hasDecoration) }.reduce(0, +) * Double(amount)
    guard area != 0 else { return price }
    return price * Double(area)
  }

  func priceString(laundry: Laundry, _ count: Int? = nil) -> String {
    let price = self.price(laundry: laundry, count)
    return price.currencyString
  }
}
