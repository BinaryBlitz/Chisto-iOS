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
  var treatmentId: Int? = nil
  var price: Double = 0

  required init?(map: Map) { }

  var treatment: Treatment? {
    guard let treatmentId = treatmentId else { return nil }
    let realm = try! Realm()
    return realm.object(ofType: Treatment.self, forPrimaryKey: treatmentId)
  }

  func mapping(map: Map) {
    price <- map["price"]
    treatmentId <- map["treatment_id"]
    id <- map["id"]
  }

}
