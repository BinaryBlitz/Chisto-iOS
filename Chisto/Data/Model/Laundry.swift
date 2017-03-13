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
  dynamic var rating: Float = 0
  dynamic var backgroundImageUrl: String = ""
  dynamic var logoUrl: String = ""
  dynamic var collectionFrom: Date = Date()
  dynamic var collectionTo: Date = Date()
  dynamic var deliveryFrom: Date = Date()
  dynamic var deliveryTo: Date = Date()
  dynamic var deliveryFee: Double = 0
  dynamic var ratingsCount: Int = 0
  dynamic var minimumOrderPrice: Double = 0
  dynamic var freeDeliveryFrom: Double = 0
  var laundryTreatments: [LaundryTreatment] = []
  var laundryItems: [LaundryItem] = []

  var collectionTimeInterval: String {
    return String(format: NSLocalizedString("timeInterval", comment: "Time interval"), collectionFrom.time, collectionTo.time)
  }

  var deliveryTimeInterval: String {
    return String(format: NSLocalizedString("timeInterval", comment: "Time interval"), deliveryFrom.time, deliveryTo.time)
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

  var isDisabled: Bool {
    return OrderManager.instance.price(laundry: self, includeCollection: false) < minimumOrderPrice
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
    deliveryFrom <- (map["delivery_from"], StringToDateTransform())
    deliveryTo <- (map["delivery_to"], StringToDateTransform())
    collectionFrom <- (map["collection_from"], StringToDateTransform())
    collectionTo <- (map["collection_to"], StringToDateTransform())
    deliveryFee <- map["delivery_fee"]
    freeDeliveryFrom <- map["free_delivery_from"]
    minimumOrderPrice <- map["minimum_order_price"]
  }
}
