//
//  GroupedSequence.swift
//  Chisto
//
//  Created by Алексей on 23.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

extension Sequence {
  /// Returns a dictionary containing all the elements grouped by a hashable parameter
  ///
  /// - Parameter _ key: (Iterator.Element) -> Type): Closure that takes every element
  /// of the sequence as a parameter and returns
  /// hashable key
  /// - Returns: A dictionary [Type: [Iterator.Element]] where Type is a hashable key
  /// from the closure return value, [Iterator.Element] is a subsequence from the original
  /// one where every item has the same key as others
  func categorize<Type:Hashable>(_ key: (Iterator.Element) -> Type) -> [Type: [Iterator.Element]] {
    var dictionary: [Type: [Iterator.Element]] = [:]
    for element in self {
      let key = key(element)
      if dictionary[key]?.append(element) == nil { dictionary[key] = [element] }
    }
    return dictionary
  }
}
