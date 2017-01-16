//
//  Subscription.swift
//  Chisto
//
//  Created by Алексей on 15.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class Subscription: Mappable {
  var content: String = ""
  var phoneNumber: String = ""

  func mapping(map: Map) {
    content <- map["content"]
    phoneNumber <- map["phone_number"]
  }

  required init(map: Map) { }

  init(phoneNumber: String, content: String) {
    self.phoneNumber = phoneNumber
    self.content = content
  }

}
