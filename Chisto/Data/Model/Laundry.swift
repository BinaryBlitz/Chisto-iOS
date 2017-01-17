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
  case fast
  case cheap
}

// TODO: remove test data and change properties
class Laundry: ServerObject {
  let dateFormatType = Date.DateStringFormatType.fullDate
  dynamic var city: City? = nil
  dynamic var name: String = ""
  dynamic var descriptionText: String = ""
  dynamic var collectionDate: Date = Date()
  dynamic var rating: Float = 0
  dynamic var backgroundImageUrl: String = ""
  dynamic var logoUrl: String = ""
  dynamic var deliveryDateOpensAt: String = "00:00"
  dynamic var deliveryDateClosesAt: String = "23:59"
  dynamic var deliveryFee: Double = 0
  dynamic var deliveryDate: Date = Date()
  dynamic var ratingsCount: Int = 0
  dynamic var minOrderPrice: Double = 0
  dynamic var freeDeliveryFrom: Double = 0
  var laundryTreatments: [LaundryTreatment] = []
  var laundryItems: [LaundryItem] = []

  var deliveryTimeInterval: String  {
    return "с \(deliveryDateOpensAt) до \(deliveryDateClosesAt)"
  }

  func collectionPrice(amount: Double) -> Double {
    guard amount < freeDeliveryFrom else { return 0 }
    return deliveryFee
  }
  
  var treatments: [Treatment] {
    return laundryTreatments
      .filter { $0.treatment != nil }
      .map { $0.treatment! }
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
    logoUrl <- map["logo_url"]
    rating <- map["rating"]
    ratingsCount <- map["ratings_count"]
    backgroundImageUrl <- map["background_image_url"]
    laundryTreatments <- map["laundry_treatments"]
    laundryItems <- map["laundry_items"]
    deliveryDate <- (map["delivery_date"], StringToDateTransform(type: dateFormatType))
    collectionDate <- (map["collection_date"], StringToDateTransform(type: dateFormatType))
    deliveryDateOpensAt <- map["delivery_date_opens_at"]
    deliveryDateClosesAt <- map["delivery_date_closes_at"]
    deliveryFee <- map["delivery_fee"]
    freeDeliveryFrom <- map["free_delivery_from"]
    minOrderPrice <- map["minimum_order_price"]
  }
}
