//
//  AnswersManager.swift
//  Chisto
//
//  Created by Алексей on 17.05.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import Crashlytics

enum LoggedScreen: String {
  case promoCodeAlert
  case orderReviewAlert
  case payment
  case registrationCode
  case registrationPhone
  case about
  case clothes
  case cityNotFound
  case citySelect
  case itemInfo
  case lastTimePopup
  case laundrySelect
  case locationSelect
  case onboarding
  case order
  case orderConfirm
  case profile
  case orderPlacedPopup
  case orderRegistration
  case profileContactData
  case orderInfo
  case myOrders
  case laundryReviews

  var name: String {
    switch self {
    case .promoCodeAlert:
      return "Promo Code alert"
    case .orderReviewAlert:
      return "Rate and review"
    case .payment:
      return "Payment"
    case .registrationCode:
      return "Registration Code"
    case .registrationPhone:
      return "Registration Phone"
    case .about:
      return "About App"
    case .clothes:
      return "Item Choice"
    case .cityNotFound:
      return "City not found"
    case .citySelect:
      return "City Selection"
    case .itemInfo:
      return "Item Info"
    case .lastTimePopup:
      return "Pop Up Last Order"
    case .laundrySelect:
      return "List Laundry"
    case .locationSelect:
      return "Address Selection"
    case .onboarding:
      return "Onboarding"
    case .order:
      return "Order List"
    case .orderConfirm:
      return "Laundry + Order"
    case .profile:
      return "Profile"
    case .orderPlacedPopup:
      return "Pop Up Your Order"
    case .orderRegistration:
      return "Order Registration Personal Info"
    case .profileContactData:
      return "Contact Info"
    case .orderInfo:
      return "Order Info"
    case .myOrders:
      return "My Orders"
    case .laundryReviews:
      return "Reviews"
    }
  }
}

class AnalyticsManager {
  static func logScreen(_ screen: LoggedScreen) {
    Answers.logContentView(withName: screen.name, contentType: "Screen", contentId: screen.rawValue)
  }
}
