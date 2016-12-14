//
//  Review.swift
//  Chisto
//
//  Created by Алексей on 18.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class Rating: Mappable {

  var id: Int!
  var value: Int = 0
  var author: String = ""
  var content: String = ""
  var createdAt: Date = Date()
  
  func mapping(map: Map) {
    id <- map["id"]
    value <- map["value"]
    content <- map["content"]
    createdAt <- (map["created_at"], StringToDateTransform())
  }
    
  required init?(map: Map) { }
  
  init() {
    id = UUID().hashValue
  }
  
}
