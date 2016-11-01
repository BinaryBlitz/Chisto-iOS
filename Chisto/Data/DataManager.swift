//
//  DataManager.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class DataManager {
  static let instance = DataManager()
  
  var currentOrderItems = BehaviorSubject<[OrderItem]>(value: [])
  
  func updateOrderItem(item: OrderItem, closure: (Void) -> Void) {
    closure()
    
    var items = try! currentOrderItems.value()
    if items.first(where: { $0.id == item.id }) == nil {
      items.append(item)
    }
    
    currentOrderItems.onNext(items)
  }
  
}
