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
  var clothesIcon: UIImage? { get }
  var clothesTitle: String { get }
  var clothesServices: [Service] { get }

}
class OrderConfirmServiceTableViewCellModel: OrderConfirmServiceTableViewCellModelType {
  var clothesIcon: UIImage?
  var clothesTitle: String
  var clothesServices: [Service]
  
  init(orderItem: OrderItem) {
    self.clothesIcon = orderItem.clothesItem.icon
    self.clothesTitle = orderItem.clothesItem.name + "× \(orderItem.amount)"
    self.clothesServices = orderItem.services
  }
}
