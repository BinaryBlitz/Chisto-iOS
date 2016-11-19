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
  var clothesTitle: String { get }
  var clothesPrice: String { get }
  var clothesServices: [Treatment] { get }
  var laundry: Laundry { get }
}

class OrderConfirmServiceTableViewCellModel: OrderConfirmServiceTableViewCellModelType {

  let clothesIconUrl: URL?
  let clothesTitle: String
  let clothesPrice: String
  let clothesServices: [Treatment]
  let laundry: Laundry

  init(orderItem: OrderItem, laundry: Laundry) {
    self.laundry = laundry
    self.clothesIconUrl = URL(string: orderItem.clothesItem.icon)
    self.clothesTitle = orderItem.clothesItem.name + " " + orderItem.priceString(laundry: laundry, 1) + " × \(orderItem.amount)"
    self.clothesPrice = orderItem.priceString(laundry: laundry)
    self.clothesServices = orderItem.treatments
  }

}
