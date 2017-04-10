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
  var discount: Decimal = 0

  func mapping(map: Map) {
    id <- map["id"]
    code <- map["code"]
    var discountValue: Double = NSDecimalNumber(decimal: discount).doubleValue
    discountValue <- map["discount"]
    discount = Decimal(discountValue)
  }

  required init(map: Map) {}

}
