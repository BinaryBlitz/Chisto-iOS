//
//  StringToDateTransform.swift
//  Chisto
//
//  Created by Алексей on 27.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper

struct StringToDateTransform: TransformType {
  let type: Date.DateStringFormatType
  
  init(type: Date.DateStringFormatType = .fullTime) {
    self.type = type
  }
  
  typealias Object = Date
  typealias JSON = String
  
  public func transformFromJSON(_ value: Any?) -> Object? {
    guard let value = value as? String else { return nil }
    return Date.fromISO8601String(string: value, type: type)
    
  }
  
  public func transformToJSON(_ value: Object?) -> JSON? {
    guard let date = value else { return "" }
    return date.description
  }
  
}
