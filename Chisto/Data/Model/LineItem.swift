//
//  LineItem.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm

class LineItem: ServerObject {
  dynamic var price: Int = 0
  var laundryTreatment: LaundryTreatment? = nil

  override func mapping(map: Map) {
    super.mapping(map: map)

    laundryTreatment <- map["laundry_treatment"]
    price <- map["price"]
  }

}
