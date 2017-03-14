//
//  OrderLineItem.swift
//  Chisto
//
//  Created by Алексей on 21.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

import Foundation
import ObjectMapper
import RealmSwift
import Realm
import ObjectMapper_Realm

class OrderItemTreatment: Mappable {
  var orderItemId: Int? = nil
  var treatment: Treatment? = nil

  var price: Decimal = 0

  required init?(map: Map) {}

  func mapping(map: Map) {
    orderItemId <- map["order_item_id"]
    price <- (map["price"], DecimalTransform())
    treatment <- map["treatment"]
  }
}

class OrderLineItem: Mappable {
  var id: Int = UUID().hashValue
  var orderTreatments: [OrderItemTreatment] = []
  var itemId: Int? = nil
  var quantity: Int = 1
  var area: Decimal = 1
  var multiplier: Double = 1
  var hasDecoration: Bool = false
  var laundryTreatmentId: Int? = nil

  var decorationPrice: Decimal {
    let price = self.price(singleItem: true, includeDecoration: false)
    return price * Decimal(multiplier) - price
  }

  var item: Item? {
    guard let item = orderTreatments.first?.treatment?.item else {
      let realm = try! Realm()
      return realm.object(ofType: Item.self, forPrimaryKey: itemId)
    }
    return item
  }

  required init?(map: Map) {}

  func mapping(map: Map) {
    orderTreatments <- map["order_treatments"]
    quantity <- map["quantity"]
    itemId <- map["item_id"]
    laundryTreatmentId <- map["laundry_treatment_id"]
    area <- (map["area"], DecimalTransform())
    hasDecoration <- map["has_decoration"]
    multiplier <- map["multiplier"]
  }
  
  func price(singleItem: Bool = false, includeDecoration: Bool = true) -> Decimal {
    let price = orderTreatments.map { (singleItem ? $0.price : $0.price * Decimal(quantity)) * area }.reduce(0, +)
    guard hasDecoration, includeDecoration else { return price }
    return price * Decimal(multiplier)
  }
}
