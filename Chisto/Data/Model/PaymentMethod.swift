//
//  PaymentMethod.swift
//  Chisto
//
//  Created by Алексей on 15.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation

enum PaymentMethod: String {
  case card = "card"
  case cash = "cash"
  case applePay = "apple_pay"

  var description: String {
    switch self {
    case .card:
      return "Карта"
    case .cash:
      return "Наличные"
    case .applePay:
      return "Apple Pay"
    }
  }
}
