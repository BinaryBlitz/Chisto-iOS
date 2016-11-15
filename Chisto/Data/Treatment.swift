//
//  Treatment.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class Treatment: ServerObjct {

  dynamic var name: String = ""
  dynamic var descriptionText: String = ""
  var item: Item? = nil

  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
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
