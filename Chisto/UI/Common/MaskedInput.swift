//
//  MaskedTextField.swift
//  Chisto
//
//  Created by Алексей on 03.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PhoneNumberKit

extension String {
  var onlyDigits: String {
    return components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
  }
}

class MaskedInput {
  enum FormattingType {
    case phoneNumber
    case pattern(String)
  }

  var type: FormattingType
  var replacementChar: String = "*"

  var isValid = Variable(false)

  init(formattingType: FormattingType) {
    self.type = formattingType
  }

  func configure(textField: UITextField) {
    _ = textField.rx.text
      .takeUntil(textField.rx.deallocated).subscribe(onNext: { [weak self] text in
      guard let formattingType = self?.type, let text = text else { return }
        switch formattingType {
        case .phoneNumber:
          let formattedPhone = PartialFormatter().formatPartial(text)
          textField.rx.text.onNext(formattedPhone)
          _ = try? PhoneNumberKit().parse(formattedPhone)
          self?.isValid.value = true
        case .pattern(let formattingPattern):
          if text.characters.count > 0, formattingPattern.characters.count > 0 {
            let formattedText = self?.format(text: text, formattingPattern: formattingPattern)

            textField.rx.text.onNext(formattedText)

            self?.isValid.value = formattedText?.characters.count == formattingPattern.characters.count
          }
        }

    })
  }

  private func format(text: String, formattingPattern: String) -> String {
    let onlyDigitsString = text.onlyDigits

    var finalText = ""

    var formatterIndex = formattingPattern.startIndex
    var tempIndex = onlyDigitsString.startIndex

    while !(formatterIndex >= formattingPattern.endIndex || tempIndex >= onlyDigitsString.endIndex) {
      let formattingPatternRange = formatterIndex ..< formattingPattern.index(formatterIndex, offsetBy: 1)

      if formattingPattern.substring(with: formattingPatternRange) != replacementChar {
        finalText = finalText + formattingPattern.substring(with: formattingPatternRange)
      } else if onlyDigitsString.characters.count > 0 {
        let pureStringRange = tempIndex ..< onlyDigitsString.index(tempIndex, offsetBy: 1)
        finalText = finalText + onlyDigitsString.substring(with: pureStringRange)
        tempIndex = onlyDigitsString.index(after: tempIndex)
      }
      formatterIndex = formattingPattern.index(after: formatterIndex)
    }

    return finalText
  }

}
