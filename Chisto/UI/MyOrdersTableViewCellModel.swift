//
//  MyOrdersTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

protocol MyOrdersTableViewCellModelType {
  var icon: UIImage? { get }
  var orderNumberTitle: String { get }
  var dateStatusTitle: String { get }
  var priceTitle: String { get }
}

class MyOrdersTableViewCellModel: MyOrdersTableViewCellModelType {
  var icon: UIImage? = nil
  let orderNumberTitle: String
  let dateStatusTitle: String
  var priceTitle: String
  
  init(order: Order) {
    self.orderNumberTitle = "Заказ № \(order.id)"
    self.dateStatusTitle = order.createdAt.mediumDate  + " ･ " + order.status.description
    self.priceTitle = order.totalPrice.currencyString
    self.icon = order.status.image
  }
  
}
