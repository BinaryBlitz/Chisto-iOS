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
  
  static func ==(lhs: LineItemInfo, rhs: LineItemInfo) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

class OrderTreatment: ServerObject {
  dynamic var name: String = ""
  dynamic var descriptionText: String = ""
  dynamic var itemId: Int = UUID().hashValue
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
    itemId <- map["item_id"]
  }
}

class OrderLaundryTreatment: ServerObject {
  dynamic var orderTreatment: OrderTreatment?
  dynamic var price: Int = 0
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    
    orderTreatment <- map["treatment"]
    price <- map["price"]
  }
}

class OrderLineItem: ServerObject {
  dynamic var orderLaundryTreatment: OrderLaundryTreatment?
  dynamic var quantity: Int = 0
  
  var item: Item? {
    guard let realm = self.realm else { return nil }
    return realm.object(ofType: Item.self, forPrimaryKey: orderLaundryTreatment?.orderTreatment?.itemId)
  }
  
  var lineItemInfo: LineItemInfo {
    return LineItemInfo(item: item, quantity: quantity)
  }

  func price(amount: Int? = nil) -> Int {
    guard let orderLaundryTreatmentPrice = orderLaundryTreatment?.price else { return 0 }
    guard let amount = amount else { return orderLaundryTreatmentPrice * quantity }
    return amount * orderLaundryTreatmentPrice
  }
  
  func priceString(amount: Int? = nil) -> String {
    let price = self.price(amount: amount)
    
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    
    orderLaundryTreatment <- map["laundry_treatment"]
    quantity <- map["quantity"]
  }
  
}
