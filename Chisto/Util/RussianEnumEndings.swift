//
//  RussianEnumEndings.swift
//  Chisto
//
//  Created by Алексей on 14.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

/// Склоняет падежи существительных, находящихся после числительных (актуально для русского языка)
///
/// - Parameters:
///   - number: Число
///   - endings: ["слово", "слова", "слов"] - необходимо передать 3 возможных окончания
/// - Returns: Правильное слово
func getRussianNumEnding(number: Int, endings: [String]) -> String {
  let number = number % 100

  if number >= 11 && number <= 19 {
    return endings[2]
  } else {
    switch number % 10 {
    case 1:
      return endings[0]
    case 2 ... 4:
      return endings[1]
    default:
      return endings[2]
    }
  }
}
