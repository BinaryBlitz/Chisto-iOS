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
  @objc dynamic var city: City? = nil
  @objc dynamic var name: String = ""
  @objc dynamic var descriptionText: String = ""
  @objc dynamic var rating: Float = 0
  @objc dynamic var backgroundImageUrl: String = ""
  @objc dynamic var logoUrl: String = ""
  @objc dynamic var collectionFrom: Date = Date()
  @objc dynamic var collectionTo: Date = Date()
  @objc dynamic var deliveryFrom: Date = Date()
  @objc dynamic var deliveryTo: Date = Date()
  @objc dynamic var deliveryFee: Double = 0
  @objc dynamic var ratingsCount: Int = 0
  @objc dynamic var minimumOrderPrice: Double = 0
  @objc dynamic var freeDeliveryFrom: Double = 0
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
