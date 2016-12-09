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

class LaundryTreatment: ServerObject {
  dynamic var price: Int = 0

  var treatment: Treatment? {
    guard let realm = self.realm else { return nil }
    return realm.object(ofType: Treatment.self, forPrimaryKey: id)
  }

  override func mapping(map: Map) {
    super.mapping(map: map)
    price <- map["price"]
  }

}
