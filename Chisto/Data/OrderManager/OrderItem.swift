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

  var area: Double? {
    guard let size = size else { return nil }
    let area = Double(size.length * size.width) / squareCentimetersInMeter
    return area
  }

  func price(laundry: Laundry, _ count: Int? = nil, includeDecoration: Bool = true) -> Double {
    let amount = count ?? self.amount

    let price = treatments.map { $0.price(laundry: laundry, hasDecoration: (hasDecoration && includeDecoration)) }.reduce(0, +) * Double(amount)
    guard let area = area else { return price }
    return price * Double(area)
  }

  func decorationPrice(laundry: Laundry) -> Double {
    return price(laundry: laundry, includeDecoration: true) - price(laundry: laundry, includeDecoration: false)
  }
}
