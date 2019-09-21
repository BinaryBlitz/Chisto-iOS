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
  let dateFormatType = Date.DateStringFormatType.fullDate
  @objc dynamic var isCreated: Bool = false
  @objc dynamic var isVerified: Bool = false
  @objc dynamic var id: Int = UUID().hashValue
  @objc dynamic var deviceToken: String? = nil
  @objc dynamic var order: Order? = nil
  @objc dynamic var firstName: String = ""
  @objc dynamic var lastName: String = ""
  @objc dynamic var phone: String = ""
  @objc dynamic var email: String = ""
  @objc dynamic var streetName: String = ""
  @objc dynamic var city: City? = nil
  @objc dynamic var building: String = ""
  @objc dynamic var apartment: String = ""
  @objc dynamic var birthdayDate: Date? = nil
  @objc dynamic var apiToken: String? = nil
  @objc dynamic var verificationToken: String? = nil
  @objc dynamic var ordersCount: Int = 0
  @objc dynamic var notes: String = ""
  @objc dynamic var disabledDecorationAlert: Bool = false
  @objc dynamic var paymentMethodRaw = PaymentMethod.applePay.rawValue
  var paymentMethod: PaymentMethod {
    get {
      return PaymentMethod(rawValue: paymentMethodRaw) ?? .applePay
    }
    set {
      paymentMethodRaw = newValue.rawValue
    }
  }

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
    birthdayDate <- (map["birthdate"], StringToDateTransform(type: dateFormatType))
    streetName <- map["street_name"]
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
