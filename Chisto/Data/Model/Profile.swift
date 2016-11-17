//
//  Profile.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

class Profile: Object {
  dynamic var id: Int = UUID().hashValue
  dynamic var city: City? = nil
  dynamic var firstName: String = ""
  dynamic var lastName: String = ""
  dynamic var phone: String = ""
  dynamic var email: String = ""
  dynamic var street: String = ""
  dynamic var building: String = ""
  dynamic var apartment: String = ""
  dynamic var apiToken: String? = nil
  
  required init(value: Any, schema: RLMSchema) {
    super.init(value: value, schema: schema)
  }
  
  required init(realm: RLMRealm, schema: RLMObjectSchema) {
    super.init(realm: realm, schema: schema)
  }
  
  required init() {
    super.init()
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }

}
