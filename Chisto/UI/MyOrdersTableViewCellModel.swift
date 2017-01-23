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
  var dateStatusTitle: NSAttributedString { get }
  var priceTitle: String { get }
}

class MyOrdersTableViewCellModel: MyOrdersTableViewCellModelType {
  var icon: UIImage? = nil
  let orderNumberTitle: String
  let dateStatusTitle: NSAttributedString
  var priceTitle: String
  
  init(order: Order) {
    self.orderNumberTitle = "Заказ № \(order.id)"
    let dateStatusString = NSMutableAttributedString()
    let dateTitle = NSAttributedString(string: order.createdAt.mediumDate)
    let statusTitle = NSAttributedString(string: order.status.description, attributes: [NSForegroundColorAttributeName: UIColor.black])
    dateStatusString.append(dateTitle)
    dateStatusString.append(NSAttributedString(string: " ･ "))
    dateStatusString.append(statusTitle)
    self.dateStatusTitle = dateStatusString
    self.priceTitle = order.totalPrice.currencyString
    self.icon = order.status.image
  }
  
}
