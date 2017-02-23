//
//  LaundryItem.swift
//  Chisto
//
//  Created by Алексей on 12.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift
import ObjectMapper_Realm

class LaundryItem: Mappable {

  var id: Int = 0
  var itemId: Int? = nil
  var decorationMultiplier: Double = 1.0

  required init?(map: Map) {}

  init() {}

  var item: Item? {
    guard let itemId = itemId else { return nil }
    let realm = try! Realm()
    return realm.object(ofType: Item.self, forPrimaryKey: itemId)
  }

  func mapping(map: Map) {
    id <- map["id"]
    itemId <- map["item_id"]
    decorationMultiplier <- map["decoration_multiplier"]
  }

}
