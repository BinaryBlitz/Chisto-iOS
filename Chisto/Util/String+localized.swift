//
//  String+localized.swift
//  Chisto
//
//  Created by Алексей on 17.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

extension String {
  func localized(_ tableName: String? = nil) -> String {
    return NSLocalizedString(self, tableName: tableName, bundle: Bundle.main, value: "", comment: "")
  }
}
