//
//  LaundryTreatment.swift
//  Chisto
//
//  Created by Алексей on 05.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift
import ObjectMapper_Realm

class LaundryTreatment: Mappable {

  var id: Int = 0
  var price: Double = 0
  var decorationMultiplier: Double = 1.0

  required init?(map: Map) { }

  init() { }

  var treatment: Treatment? {
    let realm = try! Realm()
    return realm.object(ofType: Treatment.self, forPrimaryKey: id)
  }

  func mapping(map: Map) {
    price <- map["price"]
    id <- map["id"]
    decorationMultiplier <- map["decoration_multiplier"]
  }

}
