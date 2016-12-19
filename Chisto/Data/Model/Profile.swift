//
//  Profile.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

class Profile: Object, Mappable {
  let dateFormat = "yyyy-MM-dd"
  dynamic var isCreated: Bool = false
  dynamic var id: Int = UUID().hashValue
  dynamic var deviceToken: String? = nil
  dynamic var order: Order? = nil
  dynamic var firstName: String = ""
  dynamic var lastName: String = ""
  dynamic var phone: String = ""
  dynamic var email: String = ""
  dynamic var street: String = ""
  dynamic var city: City? = nil
  dynamic var building: String = ""
  dynamic var apartment: String = ""
  dynamic var birthdayDate: Date? = nil
  dynamic var apiToken: String? = nil
  dynamic var verificationToken: String? = nil
  dynamic var ordersCount: Int = 0
  dynamic var notes: String = ""

  private var cityId: Int? {
    return city?.id
  }
  
  required init?(map: Map) {
    super.init()
  }
  
  required init(value: Any, schema: RLMSchema) {
    super.init(value: value, schema: schema)
  }
  
  required init(realm: RLMRealm, schema: RLMObjectSchema) {
    super.init(realm: realm, schema: schema)
  }
  
  required init() {
    super.init()
  }
  
  func mapping(map: Map) {
    firstName <- map["first_name"]
    lastName <- map["last_name"]
    email <- map["email"]
    phone <- map["phone_number"]
    birthdayDate <- (map["birthdate"], StringToDateTransform(format: dateFormat))
    street <- map["street_name"]
    building <- map["house_number"]
    apartment <- map["apartment_number"]
    apiToken <- map["api_token"]
    verificationToken <- map["verification_token"]
    notes <- map["notes"]
    ordersCount <- map["orders_count"]
    cityId >>> map["city_id"]
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }

}
