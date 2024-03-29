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
import RxSwift
import RxCocoa

class ServerObject: Object, Mappable {
  @objc dynamic var id: Int = UUID().hashValue
  @objc dynamic var isDeleted: Bool = false

  required init(map: Map) {
    super.init()
    mapping(map: map)
  }

  required init(value: Any, schema: RLMSchema) {
    super.init(value: value, schema: schema)
  }

  required init(realm: RLMRealm, schema: RLMObjectSchema) {
    super.init(realm: realm, schema: schema)
  }

  required init() {
    super.init()
  }

  func mapping(map: Map) {
    id <- map["id"]
  }

  override static func primaryKey() -> String? {
    return "id"
  }

}
