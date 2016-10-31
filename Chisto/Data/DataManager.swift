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

class OrderItem {
  var id = UUID().uuidString
  var clothesItem: ClothesItem
  var services: [Service]
  var amount: Int
  init (clothesItem: ClothesItem, services: [Service], amount: Int = 1) {
    self.clothesItem = clothesItem
    self.services = services
    self.amount = amount
  }
}

class DataManager {
  static let instance = DataManager()
  
  var currentOrderItems = BehaviorSubject<[OrderItem]>(value: [])
  
  func updateOrderItem(item: OrderItem, closure: (OrderItem) -> Void) {
    var items = try! currentOrderItems.value()
    if let orderItem = items.filter({ $0.id == item.id }).first {
      closure(orderItem)
    } else {
      closure(item)
      items.append(item)
    }
    currentOrderItems.onNext(items)
  }
  
}
