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
      guard let orderItems = try! self?.currentOrderItems.value() else { return Observable.empty() }
      
      for orderItem in orderItems {
        for treatment in orderItem.treatments {

          guard let laundryTreatment = laundry.laundryTreatments.first(where: {
            $0.treatmentId == treatment.id }) else { return Observable.error(DataError.requestConvertError) }

          if orderItem.area == 0 {
            let lineItemAttribute = LineItemAttribute(
              laundryTreatment.id,
              quantity: orderItem.amount
            )
            order.lineItemsArttributes.append(lineItemAttribute)
          } else {
            let lineItemAtributes = [LineItemAttribute](repeating: LineItemAttribute(laundryTreatment.id, quantity: orderItem.area),
              count: orderItem.amount)
            order.lineItemsArttributes += lineItemAtributes
          }
          
        }
      }
      
      return DataManager.instance.createOrder(order: order, laundry: laundry)
    }
  }
  
  func priceForCurrentLaundry(includeCollection: Bool = false) -> Double {
    guard let laundry = currentLaundry else { return 0 }
    return self.price(laundry: laundry, includeCollection: includeCollection)
  }
  
  func clearOrderItems() {
    currentOrderItems.onNext([])
  }

  func price(laundry: Laundry, includeCollection: Bool = false) -> Double {
    let items = try! currentOrderItems.value()
    let price = items.map { $0.price(laundry: laundry) }.reduce(0, +)
    guard includeCollection else { return price }
    return price + laundry.collectionPrice(amount: price)
  }

  func collectionPrice(laundry: Laundry) -> Double {
    return laundry.collectionPrice(amount: price(laundry: laundry))
  }

}
