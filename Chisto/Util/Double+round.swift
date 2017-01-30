//
//  Double+round.swift
//  Chisto
//
//  Created by Алексей on 30.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation

extension Double {
  func roundTo(places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
