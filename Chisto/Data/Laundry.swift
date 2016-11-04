//
//  Laundry.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class LaundryRLM: ChistoObject {
  dynamic var name: String = ""
  dynamic var descriptionText: String = ""
  dynamic var category: String = ""
  dynamic var backgroundImageUrl: String? = nil
  dynamic var logoUrl: String? = nil
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
    category <- map["category"]
    backgroundImageUrl <- map["backgroundImageUrl"]
    logoUrl <- map["logoUrl"]

  }
  
}
