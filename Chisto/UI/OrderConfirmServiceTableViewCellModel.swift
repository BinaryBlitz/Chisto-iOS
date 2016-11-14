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
  var clothesServices: [Treatment] { get }

}
class OrderConfirmServiceTableViewCellModel: OrderConfirmServiceTableViewCellModelType {
  var clothesIconUrl: URL?
  var clothesTitle: String
  var clothesServices: [Treatment]
  
  init(orderItem: OrderItem) {
    self.clothesIconUrl = URL(string: orderItem.clothesItem.icon)
    self.clothesTitle = orderItem.clothesItem.name + "× \(orderItem.amount)"
    self.clothesServices = orderItem.treatments
  }
}
