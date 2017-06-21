//
//  Order.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import PassKit
import ObjectMapper_Realm
import RealmSwift
import Crashlytics

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
      return #imageLiteral(resourceName:"iconIndicatorCompleted")
    case .errored:
      return #imageLiteral(resourceName:"iconIndicatorCanceled")
    case .cleaning:
      return #imageLiteral(resourceName:"iconIndicatorCleaning")
    case .processing:
      return #imageLiteral(resourceName:"iconIndicatorProcessing")
    case .dispatched:
      return #imageLiteral(resourceName:"iconIndicatorDispatched")
    case .canceled:
      return #imageLiteral(resourceName:"iconIndicatorCanceled")
    case .confirmed:
      return #imageLiteral(resourceName:"iconIndicatorConfirmed")
    }
  }

  var description: String {
    switch self {
    case .completed:
      return NSLocalizedString("completed", comment: "Order status")
    case .errored:
      return NSLocalizedString("errored", comment: "Order status")
    case .cleaning:
      return NSLocalizedString("cleaning", comment: "Order status")
    case .processing:
      return NSLocalizedString("processing", comment: "Order status")
    case .dispatched:
      return NSLocalizedString("dispatched", comment: "Order status")
    case .canceled:
      return NSLocalizedString("canceled", comment: "Order status")
    case .confirmed:
      return NSLocalizedString("confirmed", comment: "Order status")
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
  dynamic var deliveryPriceRaw: String = ""
  var deliveryPrice: Decimal {
    get {
      return Decimal(string: deliveryPriceRaw) ?? 0
    }
    set {
      deliveryPriceRaw = NSDecimalNumber(decimal: newValue).stringValue
    }
  }
  dynamic var createdAt: Date = Date()
  dynamic var updatedAt: Date = Date()
  dynamic var totalPriceRaw: String = ""
  var totalPrice: Decimal {
    get {
      return Decimal(string: totalPriceRaw) ?? 0
    }
    set {
      totalPriceRaw = NSDecimalNumber(decimal: newValue).stringValue
    }
  }
  dynamic var payment: Payment? = nil
  dynamic var rating: Rating? = nil
  var orderItems: [OrderLineItem] = []
  var promoCode: PromoCode? = nil

  var ratingRequiredKey: String {
    return "ratingRequired\(laundryId)"
  }

  var orderPrice: Decimal {
    guard let promoCode = promoCode else { return totalPrice - deliveryPrice }
    return totalPrice / (1 - promoCode.discount / 100) - deliveryPrice
  }

  var promoCodeDiscount: Decimal {
    return totalPrice - (orderPrice + deliveryPrice)
  }

  dynamic var paymentMethodRaw: String = "cash"

  var paymentMethod: PaymentMethod {
    get {
      return PaymentMethod(rawValue: paymentMethodRaw) ?? .cash
    }
    set {
      paymentMethodRaw = newValue.rawValue
    }
  }

  var ratingRequired: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: ratingRequiredKey)
    }
    get {
      return UserDefaults.standard.value(forKey: ratingRequiredKey) as? Bool ?? true
    }
  }

  var paymentRequest: PKPaymentRequest {
    let request = PKPaymentRequest()

    request.currencyCode = "RUB"
    request.countryCode = "RU"
    request.paymentSummaryItems = paymentSummaryItems
    request.supportedNetworks = [.masterCard, .visa]
    request.merchantCapabilities = [.capability3DS]
    request.requiredShippingAddressFields = [.name, .postalAddress]
    request.merchantIdentifier = "merchant.ru.binaryblitz.Chisto"

    // Encrypt and send order ID
    request.applicationData = try! JSONSerialization.data(withJSONObject: ["order_id": id])

    return request
  }

  private var paymentSummaryItems: [PKPaymentSummaryItem] {
    var paymentItems = paymentSummaryLineItems

    if promoCode != nil {
      let promoCodeItem = PKPaymentSummaryItem(
        label: NSLocalizedString("promoCodeSummaryItem", comment: "Apple Pay summary"),
        amount: NSDecimalNumber(decimal: promoCodeDiscount)
      )
      paymentItems.append(promoCodeItem)
    }

    let deliveryItem = PKPaymentSummaryItem(
      label: NSLocalizedString("deliverySummaryItem", comment: "Apple Pay summary"),
      amount: NSDecimalNumber(decimal: deliveryPrice)
    )
    paymentItems.append(deliveryItem)

    let totalItem = PKPaymentSummaryItem(
      label: laundry?.name ?? "Chisto",
      amount: NSDecimalNumber(decimal: totalPrice),
      type: .final
    )
    paymentItems.append(totalItem)

    return paymentItems
  }

  private var paymentSummaryLineItems: [PKPaymentSummaryItem] {
    var paymentSummaryLineItems: [PKPaymentSummaryItem] = []

    for lineItem in orderItems {
      var clothesTitle = lineItem.item?.name ?? ""
      if let item = lineItem.item {
        if item.useArea {
          clothesTitle += " \(lineItem.area) м²"
        }
        clothesTitle += " x \(lineItem.quantity)"
      }

      paymentSummaryLineItems.append(PKPaymentSummaryItem(label: clothesTitle, amount: NSDecimalNumber(decimal: lineItem.price())))
    }

    return paymentSummaryLineItems
  }

  var deliveryPriceString: String {
    return deliveryPrice == 0 ? NSLocalizedString("freeDeliveryPrice", comment: "Delivery price") : deliveryPrice.currencyString
  }

  var status: OrderStatus? {
    return OrderStatus(rawValue: statusString)
  }

  func logPurchase(success: Bool = true) {
    Answers.logPurchase(withPrice: totalPrice as NSDecimalNumber, currency: "RUB", success: success as NSNumber, itemName: "Order \(id)", itemType: "Order", itemId: "\(id)", customAttributes: [:])
  }

  override func mapping(map: Map) {
    super.mapping(map: map)
    let realm = try! Realm()

    streetName <- map["street_name"]
    houseNumber <- map["house_number"]
    apartmentNumber <- map["apartment_number"]
    contactNumber <- map["contact_number"]
    notes <- map["notes"]
    email <- map["email"]
    orderItems <- map["order_items"]
    paid <- map["paid"]
    promoCode <- map["promo_code"]
    createdAt <- (map["created_at"], StringToDateTransform())
    statusString <- map["status"]
    laundryId <- map["laundry_id"]
    laundry <- map["laundry"]
    paymentMethod <- (map["payment_method"], EnumTransform<PaymentMethod>())
    if laundry == nil {
      laundry = realm.object(ofType: Laundry.self, forPrimaryKey: laundryId)
    }
    rating <- map["rating"]
    totalPrice <- (map["total_price"], DecimalTransform())
    deliveryPrice <- (map["delivery_fee"], DecimalTransform())
    updatedAt <- (map["updated_at"], StringToDateTransform())
    payment <- map["payment"]
  }

  public override class func ignoredProperties() -> [String] {
    return ["totalPrice", "deliveryPrice"]
  }

}
