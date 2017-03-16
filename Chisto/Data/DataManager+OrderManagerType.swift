//
//  DataManager+OrderManagerType.swift
//  Chisto
//
//  Created by Алексей on 16.03.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import RxSwift
import RxCocoa
import RxRealm
import SwiftyJSON
import ObjectMapper

protocol OrderManagerType {
  func createOrder(order: RequestOrder, laundry: Laundry) -> Observable<Order>
  func getOrderInfo(orderId: Int) -> Observable<Order>
}

extension DataManager: OrderManagerType {
  func createOrder(order: RequestOrder, laundry: Laundry) -> Observable<Order> {
    let orderJSON = order.toJSON()

    return networkRequest(
      method: .post,
      .createOrder(laundryId: laundry.id),
      ["order": orderJSON]
      )
      .flatMap { result -> Observable<Order> in
        guard let order = Mapper<Order>().map(JSONObject: result) else { return Observable.error(DataError.responseConvertError) }
        let realm = try! Realm()

        try realm.write {
          realm.add(order, update: true)
        }

        return Observable.just(order)
    }
  }

  func getOrderInfo(orderId: Int) -> Observable<Order> {
    return networkRequest(method: .get, .fetchOrder(orderId: orderId)).flatMap { result -> Observable<Order> in
      guard let order = Mapper<Order>().map(JSONObject: result) else { return Observable.error(DataError.responseConvertError) }
      let realm = try! Realm()

      try realm.write {
        realm.add(order, update: true)
      }

      return Observable.just(order)
    }
  }

}
