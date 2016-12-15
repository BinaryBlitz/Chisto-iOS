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

  required init(map: Map) { }
}

class Rating: Mappable {

  var id: Int!
  var value: Int = 0
  var user: User? = nil
  var content: String = ""
  var createdAt: Date = Date()
  
  func mapping(map: Map) {
    id <- map["id"]
    value <- map["value"]
    content <- map["content"]
    user <- map["user"]
    createdAt <- (map["created_at"], StringToDateTransform())
  }
    
  required init?(map: Map) { }
  
  init() {
    id = UUID().hashValue
  }
  
}
