//
//  Treatment.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

class Treatment: ServerObject {

  dynamic var name: String = ""
  dynamic var descriptionText: String = ""
  dynamic var item: Item? = nil

  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
  }

  func price(laundry: Laundry) -> Int {
    
    return laundry.treatments
      .first { $0.treatment?.id == self.id }?.price ?? 0

  }

  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)

    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }

}
