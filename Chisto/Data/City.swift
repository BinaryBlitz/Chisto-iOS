//
//  City.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class City: ChistoObject {
  dynamic var name: String = ""
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
  }
  
}
