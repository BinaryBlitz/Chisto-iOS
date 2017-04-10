//
//  DecimalTransform.swift
//  Chisto
//
//  Created by Алексей on 25.02.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

struct DecimalTransform: TransformType {
  public typealias Object = Decimal
  public typealias JSON = String

  public init() {}

  public func transformFromJSON(_ value: Any?) -> Decimal? {
    if let string = value as? String {
      return Decimal(string: string)
    }
    if let double = value as? Double {
      return Decimal(double)
    }
    return nil
  }

  public func transformToJSON(_ value: Decimal?) -> String? {
    guard let value = value else { return nil }
    return value.description
  }
}
