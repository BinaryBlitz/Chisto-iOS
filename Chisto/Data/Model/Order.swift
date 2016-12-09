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
    case .completed, .canceled:
     return #imageLiteral(resourceName: "iconIndicatorExecuted")
    case .errored:
      return #imageLiteral(resourceName: "iconIndicatorError")
    default:
      return #imageLiteral(resourceName: "iconIndicatorDuring")
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
    case .errored:
      return UIColor.chsWatermelon
    default:
      return UIColor.chsSkyBlue
    }
  }
}

class Order: ServerObject {
  
  dynamic var streetName: String = ""
  dynamic var laundryId: Int = UUID().hashValue
  dynamic var houseNumber: String = ""
  dynamic var apartmentNumber: String = ""
  dynamic var contactNumber: String = ""
  dynamic var notes: String? = nil
  dynamic var paid: Bool = false
  dynamic var statusString: String = ""
  dynamic var paymentUrl: String = ""
  dynamic var amount: Double = 0
  dynamic var email: String? = nil
  dynamic var deliveryPrice: Int = 0
  dynamic var createdAt: Date = Date()
  dynamic var updatedAt: Date = Date()
  dynamic var payment: Payment? = nil
  var lineItems = List<OrderLineItem>()
  
  var price: Int {
    return lineItems.map { $0.price() }.reduce(0, +)
  }
  
  var deliveryPriceString: String {
    return deliveryPrice == 0 ? "Бесплатно": "\(deliveryPrice) ₽"
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
    lineItems <- (map["line_items"], ListTransform<OrderLineItem>())
    paid <- map["paid"]
    createdAt <- (map["created_at"], StringToDateTransform())
    statusString <- map["status"]
    laundryId <- map["laundry_id"]
    deliveryPrice <- map["delivery_price"]
    updatedAt <- (map["updated_at"], StringToDateTransform())
    payment <- map["payment"]
  }
  
}
