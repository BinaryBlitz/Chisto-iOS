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
  
  func mapping(map: Map) {
    id <- map["id"]
    value <- map["value"]
    content <- map["content"]
  }
  
  required init?(map: Map) {
  }
  
  init() {
    id = UUID().hashValue
  }
  
  func price(laundry: Laundry) -> Int {
    var price = 0
    
    laundry.treatments
      .filter { $0.treatmentId == self.id }
      .forEach { price += $0.price }
    
    return price
  }
  
  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)
    
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
  
}
