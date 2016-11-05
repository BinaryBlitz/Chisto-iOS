//
//  ChistoObject.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

class ServerObjct: Object, Mappable {
  dynamic var id: Int
  
  required init(map: Map) {
    id = UUID().hashValue
    super.init()
  }
  
  required init(value: Any, schema: RLMSchema) {
    id = UUID().hashValue
    super.init(value: value, schema: schema)
  }
  
  required init(realm: RLMRealm, schema: RLMObjectSchema) {
    id = UUID().hashValue
    super.init(realm: realm, schema: schema)
  }
  
  required init() {
    id = UUID().hashValue
    super.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }

}
