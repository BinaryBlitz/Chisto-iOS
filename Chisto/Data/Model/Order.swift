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

enum OrderStatus: String {
  case processing = "processing"
  case confirmed = "confirmed"
  case cleaning = "cleaning"
  case dispatched = "dispatched"
  case completed = "completed"
  case canceled = "canceled"
  case errored = "errored"
  
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
    return NSLocalizedString(self.rawValue, comment: "order status")
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
  dynamic var promoCode: String = ""
  dynamic var promoCodeDiscount: Double = 0
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

  var paymentMethod: PaymentMethod {
    guard payment != nil else { return .cash }
    return .card
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
    return deliveryPrice == 0 ? NSLocalizedString("free", comment: "Delivery price") : deliveryPrice.currencyString
  }
  
  var status: OrderStatus? {
    return OrderStatus(rawValue: statusString)
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
    rating <- map["rating"]
    totalPrice <- map["total_price"]
    deliveryPrice <- map["delivery_fee"]
    updatedAt <- (map["updated_at"], StringToDateTransform())
    payment <- map["payment"]
  }
  
}
