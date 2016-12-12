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

  func price(laundry: Laundry, hasDecoration: Bool = false) -> Double {
    
    guard let laundryTreatment = laundry.laundryTreatments.first (where: { $0.treatment?.id == self.id }) else { return 0 }
    guard hasDecoration == true else { return laundryTreatment.price }
    guard let laundryItem = laundry.laundryItems.first(where: { $0.itemId == self.item?.id }) else { return laundryTreatment.price }
    return laundryTreatment.price * laundryItem.decorationMultiplier
  }

  func priceString(laundry: Laundry, hasDecoration: Bool = false) -> String {
    let price = self.price(laundry: laundry)

    return price.currencyString
  }

}
