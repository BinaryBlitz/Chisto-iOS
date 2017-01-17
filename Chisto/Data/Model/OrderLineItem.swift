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
  var orderLaundryTreatment: OrderLaundryTreatment? = nil

  var price: Double = 0

  required init?(map: Map) { }

  func mapping(map: Map) {
    orderItemId <- map["order_item_id"]
    orderLaundryTreatment <- map["laundry_treatment"]
    price <- map["price"]
  }
}

class OrderLaundryTreatment: Mappable {
  var treatment: Treatment? = nil
  var price: Double = 0

  required init?(map: Map) { }
  
  func mapping(map: Map) {
    treatment <- map["treatment"]
    price <- map["price"]
  }
}

class OrderLineItem: Mappable {
  var id: Int = UUID().hashValue
  var orderItemTreatments: [OrderItemTreatment] = []
  var itemId: Int? = nil
  var quantity: Int = 1
  var area: Double = 1
  var multiplier: Double = 1
  var hasDecoration: Bool = false
  var laundryItemId: Int? = nil

  var decorationPrice: Double {
    let price = self.price(singleItem: true, includeDecoration: false)
    return price * multiplier - price
  }
  
  var item: Item? {
    guard let itemId = itemId else { return nil }
    let realm = try! Realm()
    return realm.object(ofType: Item.self, forPrimaryKey: itemId)
  }

  required init?(map: Map) { }
  
  func mapping(map: Map) {
    orderItemTreatments <- map["order_treatments"]
    quantity <- map["quantity"]
    itemId <- map["item_id"]
    area <- map["area"]
    laundryItemId <- map["laundry_treatment_id"]
    hasDecoration <- map["has_decoration"]
    multiplier <- map["multiplier"]
  }

  func price(singleItem: Bool = false, includeDecoration: Bool = true) -> Double {
    let price = orderItemTreatments.map { (singleItem ? $0.price : $0.price * Double(quantity)) * area }.reduce(0, +)
    guard hasDecoration, includeDecoration else { return price }
    return price * multiplier
  }
}
