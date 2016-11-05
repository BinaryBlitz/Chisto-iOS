//
//  LaundryTreatment.swift
//  Chisto
//
//  Created by Алексей on 05.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm

class LaundryTreatment: ServerObjct {
  var laundryId: Int!
  var treatmentId: Int!
  var price: Int = 0
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    laundryId <- map["laundry"]
    treatmentId <- map["treatment"]
    price <- map["price"]
  }
}
