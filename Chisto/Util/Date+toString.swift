//
//  NSDate+toString.swift
//  Chisto
//
//  Created by Алексей on 05.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

extension DateFormatter {

  convenience init(dateStyle: DateFormatter.Style) {
    self.init()
    self.dateStyle = dateStyle
  }

}

extension Date {

  struct Formatter {
    static let shortDate = DateFormatter(dateStyle: .short)
  }

  var shortDate: String {
    return Formatter.shortDate.string(from: self)
  }

}
