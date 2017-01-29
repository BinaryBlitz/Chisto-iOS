//
//  PromoCode.swift
//  Chisto
//
//  Created by Алексей on 29.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class PromoCode: Mappable {
  var id: Int = 0
  var code: String = ""
  var discount: Int = 0

  func mapping(map: Map) {
    id <- map["id"]
    code <- map["code"]
    discount <- map["discount"]
  }

  required init(map: Map) { }
  
}
