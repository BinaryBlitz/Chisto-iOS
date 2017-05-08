//
//  Order.swift
//  Chisto
//
//  Created by Алексей on 13.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class RequestOrder: Mappable {

  var streetName: String = ""
  var houseNumber: String = ""
  var apartmentNumber: String = ""
  var contactNumber: String = ""
  var notes: String? = nil
  var email: String? = nil
  var orderItemsAttributes: [OrderItemAttribute] = []
  var paymentMethod: PaymentMethod = .cash
  var promoCodeId: Int? = nil

  init(profile: Profile) {
    apartmentNumber = "30"
    houseNumber = "3"
    apartmentNumber = "3"
    contactNumber = profile.phone
    streetName = "Test"
    email = profile.email
    notes = profile.notes
    paymentMethod = profile.paymentMethod
  }

  required init(map: Map) {}

  func mapping(map: Map) {
    streetName <- map["street_name"]
    houseNumber <- map["house_number"]
    apartmentNumber <- map["apartment_number"]
    contactNumber <- map["contact_number"]
    notes <- map["notes"]
    email <- map["email"]
    paymentMethod <- (map["payment_method"], EnumTransform<PaymentMethod>())
    orderItemsAttributes <- map["order_items_attributes"]
    promoCodeId <- map["promo_code_id"]
  }

}
