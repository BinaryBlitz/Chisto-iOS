//
//  OrderItemAttribute.swift
//  Chisto
//
//  Created by Алексей on 10.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderTreatmentAttribute: Mappable {

  var laundryTreatmentId: Int!

  init(_ laundryTreatmentId: Int) {
    self.laundryTreatmentId = laundryTreatmentId
  }

  required init(map: Map) {}

  func mapping(map: Map) {
    laundryTreatmentId <- map["laundry_treatment_id"]
  }
  
}

class OrderItemAttribute: Mappable {
  var quantity: Int = 0
  var area: Int? = nil
  var itemId: Int!
  var hasDecoration: Bool = false
  var orderTreatmentsAttributes: [OrderTreatmentAttribute] = []

  init(orderItem: OrderItem, laundry: Laundry) {
    self.itemId = orderItem.clothesItem.id
    self.area = orderItem.area
    self.quantity = orderItem.amount
    self.hasDecoration = orderItem.hasDecoration

    for treatment in orderItem.treatments {
      guard let laundryTreatment = laundry.laundryTreatments.first(where: {
        $0.treatmentId == treatment.id }) else { return }
      orderTreatmentsAttributes.append(OrderTreatmentAttribute(laundryTreatment.id))
    }
  }

  required init(map: Map) {}

  func mapping(map: Map) {
    itemId <- map["item_id"]
    hasDecoration <- map["has_decoration"]
    area <- map["area"]
    quantity <- map["quantity"]
    orderTreatmentsAttributes <- map["order_treatments_attributes"]

  }

}
