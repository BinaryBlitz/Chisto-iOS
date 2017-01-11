//
//  Order.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectMapper_Realm
import RealmSwift

enum OrderStatus {
  case processing
  case confirmed
  case cleaning
  case dispatched
  case completed
  case canceled
  case errored
  
  var image: UIImage {
    switch self {
    case .completed:
     return #imageLiteral(resourceName: "iconIndicatorCompleted")
    case .errored:
      return #imageLiteral(resourceName: "iconIndicatorCanceled")
    case .cleaning:
      return #imageLiteral(resourceName: "iconIndicatorCleaning")
    case .processing:
      return #imageLiteral(resourceName: "iconIndicatorProcessing")
    case .dispatched:
      return #imageLiteral(resourceName: "iconIndicatorDispatched")
    case .canceled:
      return #imageLiteral(resourceName: "iconIndicatorCanceled")
    case .confirmed:
      return #imageLiteral(resourceName: "iconIndicatorConfirmed")
    }
  }
  
  var description: String {
    switch self {
    case .processing:
      return "Обрабатывается"
    case .confirmed:
      return "Согласован забор вещей"
    case .cleaning:
      return "В чистке"
    case .dispatched:
      return "Вещи едут к вам"
    case .completed:
      return "Исполнен"
    case .errored:
      return "Ошибка"
    case .canceled:
      return "Отменён"
    }
  }
  
  var color: UIColor {
    switch self {
    case .completed:
      return UIColor.chsJadeGreen
    case .errored, .canceled:
      return UIColor.chsWatermelon
    case .processing:
      return UIColor.chsSkyBlue
    case .confirmed:
      return UIColor.chsLightSkyBlue
    case .dispatched:
      return UIColor.chsDarkYellow
    case .cleaning:
      return UIColor.chsLightBlue
    }
  }
}

class Order: ServerObject {

  dynamic var streetName: String = ""
  dynamic var laundryId: Int = UUID().hashValue
  dynamic var laundry: Laundry? = nil
  dynamic var houseNumber: String = ""
  dynamic var apartmentNumber: String = ""
  dynamic var contactNumber: String = ""
  dynamic var notes: String? = nil
  dynamic var paid: Bool = false
  dynamic var statusString: String = ""
  dynamic var paymentUrl: String = ""
  dynamic var email: String? = nil
  dynamic var deliveryPrice: Double = 0
  dynamic var createdAt: Date = Date()
  dynamic var updatedAt: Date = Date()
  dynamic var totalPrice: Double = 0
  dynamic var payment: Payment? = nil
  dynamic var rating: Rating? = nil
  var lineItems: [OrderLineItem] = []

  var ratingRequiredKey: String {
    return "ratingRequired\(laundryId)"
  }

  var orderPrice: Double {
    return totalPrice - deliveryPrice
  }

  var ratingRequired: Bool  {
    set {
      UserDefaults.standard.set(newValue, forKey: ratingRequiredKey)
    }
    get {
      return UserDefaults.standard.value(forKey: ratingRequiredKey) as? Bool ?? true
    }
  }

  var deliveryPriceString: String {
    return deliveryPrice == 0 ? "Бесплатно": deliveryPrice.currencyString
  }
  
  var status: OrderStatus {
    switch statusString {
    case "processing":
      return .processing
    case "confirmed":
      return .confirmed
    case "cleaning":
      return .cleaning
    case "dispatched":
      return .dispatched
    case "canceled":
      return .canceled
    case "completed":
      return .completed
    case "errored":
      return .errored
    default:
      return .processing
    }
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    streetName <- map["street_name"]
    houseNumber <- map["house_number"]
    apartmentNumber <- map["apartment_number"]
    contactNumber <- map["contact_number"]
    notes <- map["notes"]
    email <- map["email"]
    lineItems <- map["order_items"]
    paid <- map["paid"]
    createdAt <- (map["created_at"], StringToDateTransform())
    statusString <- map["status"]
    laundryId <- map["laundry_id"]
    laundry <- map["laundry"]
    totalPrice <- map["total_price"]
    deliveryPrice <- map["delivery_fee"]
    updatedAt <- (map["updated_at"], StringToDateTransform())
    payment <- map["payment"]
  }
  
}
