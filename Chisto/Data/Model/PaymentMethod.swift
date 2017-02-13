//
//  PaymentMethod.swift
//  Chisto
//
//  Created by Алексей on 15.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

enum PaymentMethod: String {
  case card = "card"
  case cash = "cash"
  case applePay = "apple_pay"

  var image: UIImage {
    switch self {
    case .card:
      return #imageLiteral(resourceName: "IconIndicatorCard")
    case .cash:
      return #imageLiteral(resourceName: "iconIndicatorMonye")
    case .applePay:
      return #imageLiteral(resourceName: "IconIndicatorApplepay")
    }
  }
  
  var description: String {
    switch self {
    case .card:
      return NSLocalizedString("card", comment: "Payment method")
    case .cash:
      return NSLocalizedString("cash", comment: "Payment method")
    case .applePay:
      return NSLocalizedString("apple_pay", comment: "Payment method")
    }
  }
}
