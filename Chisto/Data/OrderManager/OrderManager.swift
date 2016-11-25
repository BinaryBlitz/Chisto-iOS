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

  func placeOrder() -> Observable<Order> {
    let profile = ProfileManager.instance.userProfile.value
    guard let laundry = currentLaundry else { return Observable.empty() }

    let order = RequestOrder(profile: profile)
    let items = try! currentOrderItems.value()

    for item in items {
      for treatment in item.treatments {
        let lineItemAttribute = LineItemAttribute(
          laundryTreatmentId: treatment.id,
          quantity: item.amount
        )

        order.lineItemsArttributes.append(lineItemAttribute)
      }
    }

    return DataManager.instance.placeOrder(order: order, laundry: laundry)
  }

  var priceForCurrentLaundry: Int {
    guard let laundry = currentLaundry else { return 0 }

    return price(laundry: laundry)
  }

  var priceForCurrentLaundryString: String {
    guard let laundry = currentLaundry else { return "Бесплатно" }

    return priceString(laundry: laundry)
  }
  
  func clearOrderItems() {
    currentOrderItems.onNext([])
  }

  func price(laundry: Laundry) -> Int {
    let items = try! currentOrderItems.value()

    return items.map { $0.price(laundry: laundry) }.reduce(0, +)
  }

  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)

    return "\(price) ₽"
  }

}
