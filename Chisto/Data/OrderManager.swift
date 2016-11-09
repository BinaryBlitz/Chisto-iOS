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
  
  var currentOrderItems = BehaviorSubject<[OrderItem]>(value: [])
  var currentLaundry: Laundry? = nil
  
  func updateOrderItem(item: OrderItem, closure: (Void) -> Void) {
    closure()
    
    var items = try! currentOrderItems.value()
    if items.first(where: { $0.id == item.id }) == nil {
      items.append(item)
    }
    
    currentOrderItems.onNext(items)
  }
  
  var priceForCurrentLaundry: Int {
    guard let laundry = currentLaundry else { return 0 }
    return price(laundry: laundry)
  }
  
  var priceForCurrentLaundryString: String {
    guard let laundry = currentLaundry else { return "Бесплатно" }
    return priceString(laundry: laundry)
  }
  
  func price(laundry: Laundry) -> Int {
    var price = 0
    let items = try! currentOrderItems.value()
    for item in items {
      price += item.price(laundry: laundry)
    }
    
    return price
  }
  
  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
  
}
