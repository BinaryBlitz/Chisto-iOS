//
//  Data+hexString.swift
//  Chisto
//
//  Created by Алексей on 19.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

extension Data {

  public var hexadecimalString: String {
    var result = ""
    enumerateBytes { buffer, index, stop in
      for byte in buffer {
        result.append(String(format: "%02x", byte))
      }
    }
    return result
  }

}
