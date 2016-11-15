//
//  NSURL+QueryParams.swift
//  Chisto
//
//  Created by Алексей on 14.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

extension URL {
  
  func appendingQueryParams(parameters: [String: String]?) -> URL {
    guard
      let parameters = parameters,
      let urlComponents = NSURLComponents(url: self, resolvingAgainstBaseURL: true) else {
        return self
    }
    
    var mutableQueryItems: [URLQueryItem] = urlComponents.queryItems ?? []
    
    mutableQueryItems.append(contentsOf: parameters.map{ URLQueryItem(name: $0, value: $1) })
    urlComponents.queryItems = mutableQueryItems
    
    return urlComponents.url!
  }
  
}
