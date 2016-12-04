//
//  Laundry.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectMapper_Realm
import Realm
import RealmSwift

enum LaundryType {
  case premium
  case fast
  case cheap
}

// TODO: remove test data and change properties
class Laundry: ServerObject {
  let dateFormat = "yyyy-MM-dd"
  dynamic var city: City? = nil
  dynamic var name: String = ""
  dynamic var descriptionText: String = ""
  dynamic var collectionDate: Date = Date()
  dynamic var rating: Float = 0
  dynamic var category: String? = nil
  dynamic var backgroundImageUrl: String = ""
  dynamic var logoUrl: String = ""
  dynamic var deliveryDateOpensAt: String = "00:00"
  dynamic var deliveryDateClosesAt: String = "23:59"
  dynamic var courierPrice: Int = 0
  dynamic var deliveryDate: Date = Date()
  dynamic var ratingsCount: Int = 0
  var laundryTreatments = List<LaundryTreatment>()
  
  var deliveryTimeInterval: String  {
    return "с \(deliveryDateOpensAt) до \(deliveryDateClosesAt)"
  }
  
  var treatments: [Treatment] {
    return laundryTreatments.toArray()
      .filter { $0.treatment != nil }
      .map { $0.treatment! }
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
    category <- map["category"]
    logoUrl <- map["logo_url"]
    rating <- map["rating"]
    ratingsCount <- map["ratings_count"]
    backgroundImageUrl <- map["background_image_url"]
    laundryTreatments <- (map["laundry_treatments"], ListTransform<LaundryTreatment>())
    deliveryDate <- (map["delivery_date"], StringToDateTransform(format: dateFormat))
    collectionDate <- (map["collection_date"], StringToDateTransform(format: dateFormat))
    deliveryDateOpensAt <- map["delivery_date_opens_at"]
    deliveryDateClosesAt <- map["delivery_date_closes_at"]
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
