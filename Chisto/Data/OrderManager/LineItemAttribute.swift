//
//  LineItemAttribute.swift
//  Chisto
//
//  Created by Алексей on 13.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class LineItemAttribute: Mappable {

  var laundryTreatmentId: Int!
  var quantity: Int!

  init(_ laundryTreatmentId: Int, quantity: Int) {
    self.laundryTreatmentId = laundryTreatmentId
    self.quantity = quantity
  }

  required init(map: Map) {}

  func mapping(map: Map) {
    laundryTreatmentId <- map["laundry_treatment_id"]
    quantity <- map["quantity"]
  }

}
