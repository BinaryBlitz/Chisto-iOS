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
    static let longDate = DateFormatter(dateStyle: .full)
    static let mediumDate = DateFormatter(dateStyle: .medium)

  }

  enum DateStringFormatType: String {
    case fullTime = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case fullDate = "dd.MM.YYYYs"
  }

  var shortDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.YYYY"
    return formatter.string(from: self)
  }

  var time: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self)
  }

  var longDate: String {
    return Formatter.longDate.string(from: self)
  }

  var mediumDate: String {
    return Formatter.mediumDate.string(from: self)
  }

  static func fromISO8601String(string: String, type: DateStringFormatType = .fullTime) -> Date? {
    if #available(iOS 10.0, *) {
      let dateFormatter = ISO8601DateFormatter()
      switch type {
      case .fullDate:
        dateFormatter.formatOptions = .withFullDate
      default:
        dateFormatter.formatOptions.insert(.withTimeZone)
      }
      return dateFormatter.date(from: string)
    } else {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = type.rawValue
      return dateFormatter.date(from: string)
    }
  }
}
