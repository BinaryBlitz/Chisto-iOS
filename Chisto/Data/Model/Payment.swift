//
//  Payment.swift
//  Chisto
//
//  Created by Алексей on 25.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class Payment: ServerObject {
  dynamic var amount: Int = 0
  dynamic var isPaid: Bool = false
  dynamic var paymentUrl: String = ""
  dynamic var createdAt: String = ""

  override func mapping(map: Map) {
    super.mapping(map: map)
    amount <- map["amount"]
    isPaid <- map["paid"]
    paymentUrl <- map["payment_url"]
    createdAt <- map["created_at"]

  }

}
