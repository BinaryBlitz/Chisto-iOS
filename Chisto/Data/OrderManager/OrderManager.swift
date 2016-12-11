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
import RealmSwift

class OrderManager {

  static let instance = OrderManager()

  var currentOrderItems = BehaviorSubject<[OrderItem]>(value: [])
  var currentLaundry: Laundry? = nil

  func updateOrderItem(_ item: OrderItem, closure: (Void) -> Void) {
    closure()

    var items = try! currentOrderItems.value()

    if items.first(where: { $0.id == item.id }) == nil {
      items.append(item)
    }

    currentOrderItems.onNext(items)
  }

  func createOrder() -> Observable<Order> {
    return Observable.deferred { [weak self] in
      let profile = ProfileManager.instance.userProfile.value
      guard let laundry = self?.currentLaundry else { return Observable.empty() }
      
      let order = RequestOrder(profile: profile)
      guard let items = try! self?.currentOrderItems.value() else { return Observable.empty() }
      
      for item in items {
        for treatment in item.treatments {
          let lineItemAttribute = LineItemAttribute(
            laundryTreatmentId: treatment.id,
            quantity: item.amount
          )
          
          order.lineItemsArttributes.append(lineItemAttribute)
        }
      }
      
      return DataManager.instance.createOrder(order: order, laundry: laundry)
    }
  }
  
  func priceForCurrentLaundry(includeCollection: Bool = false) -> Int {
    guard let laundry = currentLaundry else { return 0 }
    let price = self.price(laundry: laundry)
    guard includeCollection else { return price }
    return price + laundry.collectionPrice(amount: price)
  }
  
  func clearOrderItems() {
    currentOrderItems.onNext([])
  }

  func price(laundry: Laundry, includeCollection: Bool = false) -> Int {
    let items = try! currentOrderItems.value()
    let price = items.map { $0.price(laundry: laundry) }.reduce(0, +)
    guard includeCollection else { return price }
    return price + laundry.collectionPrice(amount: price)
  }

  func collectionPrice(laundry: Laundry) -> Int {
    return laundry.collectionPrice(amount: price(laundry: laundry))
  }

}
