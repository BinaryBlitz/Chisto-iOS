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
  @objc dynamic var amount: Int = 0
  @objc dynamic var paid: Bool = false
  @objc dynamic var paymentUrl: String = ""
  @objc dynamic var createdAt: String = ""

  override func mapping(map: Map) {
    super.mapping(map: map)

    amount <- map["amount"]
    paid <- map["paid"]
    paymentUrl <- map["payment_url"]
    createdAt <- map["created_at"]
  }

}
