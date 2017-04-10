//
//  Review.swift
//  Chisto
//
//  Created by Алексей on 18.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
  var id: Int!
  var firstName: String = ""
  var lastName: String = ""

  func mapping(map: Map) {
    id <- map["id"]
    firstName <- map["first_name"]
    lastName <- map["last_name"]
  }

  required init(map: Map) {}
}

class Rating: ServerObject {

  dynamic var value: Int = 0
  dynamic var content: String = ""
  dynamic var createdAt: Date? = nil
  var user: User? = nil

  override func mapping(map: Map) {
    value <- map["value"]
    content <- map["content"]

    if map.mappingType == .fromJSON {
      user <- map["user"]
      id <- map["id"]
      createdAt <- (map["created_at"], StringToDateTransform())
    }
  }

}
