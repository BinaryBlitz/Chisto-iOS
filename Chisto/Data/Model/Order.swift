//
//  Order.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

enum OrderStatus {
  case processing
  case completed
  case errored
}

class Order: ServerObject {
  
  // TODO: remove test email
  dynamic var streetName: String = ""
  dynamic var houseNumber: String = ""
  dynamic var apartmentNumber: String = ""
  dynamic var contactNumber: String = ""
  dynamic var notes: String? = nil
  dynamic var paid: Bool = false
  dynamic var statusString: String = ""
  dynamic var paymentUrl: String = ""
  dynamic var amount: Double = 0
  dynamic var email: String? = nil
  dynamic var createdAt: String = ""
  var lineItems = List<LineItem>()
  
  var createdAtDate: Date {
    return Date.from(string: createdAt) ?? Date()
  }
  
  var status: OrderStatus {
    switch statusString {
    case "processing":
      return .processing
    case "completed":
      return .completed
    case "errored":
      return .errored
    default:
      return .processing
    }
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    streetName <- map["street_name"]
    houseNumber <- map["house_number"]
    apartmentNumber <- map["apartment_number"]
    contactNumber <- map["contact_number"]
    notes <- map["notes"]
    email <- map["email"]
    lineItems <- map["line_items"]
    paid <- map["paid"]
    createdAt <- map["created_at"]
    statusString <- map["status"]
  }
  
}
