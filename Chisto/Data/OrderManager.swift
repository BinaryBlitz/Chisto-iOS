//
//  OrderManager.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrderManager {
  static let instance = OrderManager()
  
  var currentLaundry = Variable<Laundry?>(nil)

  var currentOrderItems = BehaviorSubject<[OrderItem]>(value: [])
  
  // This function should be used to update any order item, it notifies all of the currentOrderItems observers about data change
  func updateOrderItem(item: OrderItem, closure: (Void) -> Void) {
    closure()
    
    var items = try! currentOrderItems.value()
    if items.first(where: { $0.id == item.id }) == nil {
      items.append(item)
    }
    currentOrderItems.onNext(items)
  }
  
}
