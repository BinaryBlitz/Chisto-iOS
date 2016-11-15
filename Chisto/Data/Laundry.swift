//
//  Laundry.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

enum LaundryType {
  case premium
  case fast
  case cheap
}

// TODO: remove test data and change properties
class Laundry: ServerObjct {
  dynamic var name: String = ""
  dynamic var descriptionText: String = ""
  dynamic var courierDate: Double = 0.0
  dynamic var rating: Float = 0
  dynamic var category: String? = nil
  dynamic var backgroundImageUrl: String = ""
  dynamic var logoUrl: String = ""
  dynamic var deliveryTimeInterval: String = "с 00:00 до 23:59"
  dynamic var courierPrice: Int = 0
  dynamic var deliveryDate: Double = 0.0
  var treatments = List<LaundryTreatment>()
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
    category <- map["category"]
    backgroundImageUrl <- map["logo_url"]
    logoUrl <- map["icon_url"]
    treatments <- map["laundry_treatments"]

  }
  
  var type: LaundryType? {
    guard let category = self.category else { return nil }
    switch category {
    case "premium":
      return .premium
    case "cheap":
      return .cheap
    case "fast":
      return .fast
    default:
      return nil
    }
  }
  
  var courierPriceString: String {
    return courierPrice == 0 ? "Бесплатно" : "\(courierPrice) ₽"
  }
  
}
