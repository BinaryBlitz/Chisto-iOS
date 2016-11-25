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
  case completed
  case errored
  
  var image: UIImage {
    switch self {
    case .processing:
      return #imageLiteral(resourceName: "iconIndicatorDuring")
    case .completed:
     return #imageLiteral(resourceName: "iconIndicatorExecuted")
    case .errored:
      return #imageLiteral(resourceName: "iconIndicatorError")
    }
  }
  
  var description: String {
    switch self {
    case .processing:
      return "В процессе"
    case .completed:
      return "Выполнен"
    case .errored:
      return "Ошибка"
    }
  }
  
  var color: UIColor {
    switch self {
    case .processing:
      return UIColor.chsSkyBlue
    case .completed:
      return UIColor.chsJadeGreen
    case .errored:
      return UIColor.chsWatermelon
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
  dynamic var createdAt: String = ""
  var lineItems = List<OrderLineItem>()
  
  var createdAtDate: Date {
    return Date.from(string: createdAt) ?? Date()
  }
  
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
    createdAt <- map["created_at"]
    statusString <- map["status"]
    laundryId <- map["laundry_id"]
    deliveryPrice <- map["delivery_price"]
  }
  
}
