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
  let format: String
  
  init(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
    self.format = format
  }
  
  typealias Object = Date
  typealias JSON = String
  
  public func transformFromJSON(_ value: Any?) -> Object? {
    guard let value = value as? String else { return nil }
    return Date.from(string: value, format: format)
    
  }
  
  public func transformToJSON(_ value: Object?) -> JSON? {
    guard let date = value else { return "" }
    return date.description
  }
  
}
