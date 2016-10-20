//
//  OrderTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OrderTableViewCellModelType {
  // Output
  var itemTitleText: String { get }
  var servicesText: NSAttributedString { get }
  var icon: UIImage? { get }
  var amountText: String { get }
  
  // Input
  
}


class OrderTableViewCellModel: OrderTableViewCellModelType {
  // Constants
  let itemTitleText: String
  let servicesText: NSAttributedString
  let icon: UIImage?
  let amountText: String
  
  init(item: OrderItem) {
    self.itemTitleText = item.clothesItem.name
    
    let servicesAttrString = NSMutableAttributedString()
    
    for (index, service) in item.services.enumerated() {
      servicesAttrString.append(NSAttributedString(string: service.name, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))
      if index != item.services.count - 1 {
        servicesAttrString.append(NSAttributedString(string: " • ", attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
      }
    }
  
    self.servicesText = servicesAttrString
    
    self.amountText = "x \(item.amount)"
    
    self.icon = item.clothesItem.icon
  }
  
}
