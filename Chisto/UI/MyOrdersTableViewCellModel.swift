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
  var orderNumberTitle: String = ""
  var dateStatusTitle: String = ""
  var priceTitle: String = ""
  
  init(order: Order) {
    self.orderNumberTitle = String(format: "orderNumber".localized, String(order.id))
    self.priceTitle = order.totalPrice.currencyString
    guard let status = order.status else { return }
    self.dateStatusTitle = order.createdAt.mediumDate  + " ･ " + status.description
    self.icon = status.image
  }
  
}
