//
//  Double+currencyString.swift
//  Chisto
//
//  Created by Алексей on 10.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

extension Double {
  var currencyString: String {
    let currencyFormatter = NumberFormatter()

    let localeIdentifier = "ru_RU"
    currencyFormatter.numberStyle = NumberFormatter.Style.currency
    currencyFormatter.locale = Locale(identifier: localeIdentifier)
    let fraction = self - Double(Int(self))
    currencyFormatter.minimumFractionDigits = Int(fraction * 100) == 0 ? 0 : 2
    currencyFormatter.maximumFractionDigits = 2
    return currencyFormatter.string(from: self as NSNumber) ?? ""
  }

}
