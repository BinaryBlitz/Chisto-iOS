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

struct LineItemInfo: Hashable {
  let item: Item?
  let quantity: Int
  
  var hashValue: Int {
    guard let item = item else { return quantity.hashValue }
    return item.hashValue + quantity.hashValue
  }
  
  static func == (lhs: LineItemInfo, rhs: LineItemInfo) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

class OrderTreatment: Mappable {
  var name: String = ""
  var descriptionText: String = ""
  var itemId: Int = UUID().hashValue

  required init?(map: Map) { }

  func mapping(map: Map) {
    name <- map["name"]
    descriptionText <- map["description"]
    itemId <- map["item_id"]
  }
}

class OrderLaundryTreatment: Mappable {
  var orderTreatment: OrderTreatment?
  var price: Double = 0

  required init?(map: Map) { }
  
  func mapping(map: Map) {
    orderTreatment <- map["treatment"]
    price <- map["price"]
  }
}

class OrderLineItem: Mappable {
  var orderLaundryTreatment: OrderLaundryTreatment?
  var quantity: Int = 0
  
  var item: Item? {
    let realm = try! Realm()
    return realm.object(ofType: Item.self, forPrimaryKey: orderLaundryTreatment?.orderTreatment?.itemId)
  }
  
  var lineItemInfo: LineItemInfo {
    return LineItemInfo(item: item, quantity: quantity)
  }

  func price(amount: Int? = nil) -> Double {
    guard let orderLaundryTreatmentPrice = orderLaundryTreatment?.price else { return 0 }
    guard let amount = amount else { return orderLaundryTreatmentPrice * Double(quantity) }
    return Double(amount) * orderLaundryTreatmentPrice
  }

  required init?(map: Map) { }
  
  func priceString(amount: Int? = nil) -> String {
    let price = self.price(amount: amount)
    
    return price.currencyString
  }
  
  func mapping(map: Map) {
    orderLaundryTreatment <- map["laundry_treatment"]
    quantity <- map["quantity"]
  }
  
}
