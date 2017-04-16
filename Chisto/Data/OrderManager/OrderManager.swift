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

  func createOrder(promoCode: PromoCode? = nil) -> Observable<Order> {
    return Observable.deferred { [weak self] in
      let profile = ProfileManager.instance.userProfile.value
      guard let laundry = self?.currentLaundry else { return Observable.empty() }
      guard let orderItems = try! self?.currentOrderItems.value() else { return Observable.empty() }

      let order = RequestOrder(profile: profile)
      order.promoCodeId = promoCode?.id

      order.orderItemsAttributes = orderItems.map { OrderItemAttribute(orderItem: $0, laundry: laundry) }

      return DataManager.instance.createOrder(order: order, laundry: laundry)
    }
  }

  func priceForCurrentLaundry(includeCollection: Bool = false, promoCode: PromoCode? = nil) -> Double {
    guard let laundry = currentLaundry else { return 0 }
    return self.price(laundry: laundry, includeCollection: includeCollection, promoCode: promoCode)
  }

  func clearOrderItems() {
    currentLaundry = nil
    currentOrderItems.onNext([])
  }

  func price(laundry: Laundry, includeCollection: Bool = false, promoCode: PromoCode? = nil) -> Double {
    let items = try! currentOrderItems.value()
    var price = items.map { $0.price(laundry: laundry) }.reduce(0, +)
    if includeCollection {
      price += laundry.collectionPrice(amount: price)
    }
    if let promoCode = promoCode {
      price -= price * NSDecimalNumber(decimal: promoCode.discount).doubleValue / 100
    }
    return price
  }

  func collectionPrice(laundry: Laundry) -> Double {
    return laundry.collectionPrice(amount: price(laundry: laundry))
  }

}
