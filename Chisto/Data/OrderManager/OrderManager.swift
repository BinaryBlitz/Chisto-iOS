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
import Crashlytics

/// Manages current order
class OrderManager {

  static let instance = OrderManager()

  var currentOrderItems = BehaviorSubject<[OrderItem]>(value: [])
  var currentLaundry: Laundry? = nil

  /// Updates order item and saves it if needed
  ///
  /// - Parameters:
  ///   - item: an item to update
  ///   - closure: a block which modifies the object
  func updateOrderItem(_ item: OrderItem, closure: () -> Void) {
    closure()

    var items = try! currentOrderItems.value()

    if items.first(where: { $0.id == item.id }) == nil {
      items.append(item)
    }

    currentOrderItems.onNext(items)
  }

  /// Updates order item and saves it if needed
  ///
  /// - Parameter promoCode: a promo code
  /// - Returns: an Observable containing single order object
  func createOrder(promoCode: PromoCode? = nil) -> Observable<Order> {
    return Observable.deferred { [weak self] in
      let profile = ProfileManager.instance.userProfile.value
      guard let laundry = self?.currentLaundry else { return Observable.empty() }
      guard let orderItems = try! self?.currentOrderItems.value() else { return Observable.empty() }

      let order = RequestOrder(profile: profile)
      order.promoCodeId = promoCode?.id

      order.orderItemsAttributes = orderItems.map { OrderItemAttribute(orderItem: $0, laundry: laundry) }

      return DataManager.instance.createOrder(order: order, laundry: laundry).do(onNext: {
        Answers.logCustomEvent(withName: "Order created", customAttributes: ["orderId": $0.id])
      })
    }
  }

  /// Returns order price for selected laundry
  ///
  /// - Parameters:
  ///   - includeCollection: a flag which indicates whether collection price should be included
  ///   - promoCode: a promo code, which can affect total prices
  /// - Returns: an order price
  func priceForCurrentLaundry(includeCollection: Bool = false, promoCode: PromoCode? = nil) -> Double {
    guard let laundry = currentLaundry else { return 0 }
    return self.price(laundry: laundry, includeCollection: includeCollection, promoCode: promoCode)
  }

  func clearOrderItems() {
    currentLaundry = nil
    currentOrderItems.onNext([])
  }

  /// Returns order price for selected laundry
  ///
  /// - Parameters:
  ///   - laundry: A laundry which prices should be used for counting
  ///   - includeCollection: a flag indicating whether collection price should be included
  ///   - promoCode: a promo code, which can affect total prices
  /// - Returns: an order price
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
