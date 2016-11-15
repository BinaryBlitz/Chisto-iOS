//
//  Order.swift
//  Chisto
//
//  Created by Алексей on 13.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class Order: Mappable {

  // TODO: remove test email
  var streetName: String = ""
  var houseNumber: String = ""
  var apartmentNumber: String = ""
  var contactNumber: String = ""
  var notes: String? = nil
  var email: String? = "foo@bar.com"
  var lineItemsArttributes: [LineItemAttribute] = []
  
  init(profile: Profile) {
    apartmentNumber = profile.apartment
    houseNumber = profile.building
    apartmentNumber = profile.apartment
    contactNumber = profile.phone
    streetName = profile.street
  }
  
  required init(map: Map) {}

  func mapping(map: Map) {
    streetName <- map["street_name"]
    houseNumber <- map["house_number"]
    apartmentNumber <- map["apartment_number"]
    contactNumber <- map["contact_number"]
    notes <- map["notes"]
    email <- map["email"]
    lineItemsArttributes <- map["line_items_attributes"]
  }
  
}
