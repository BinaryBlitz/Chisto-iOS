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

extension String {
  var onlyDigits: String {
    return components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
  }

}

@IBDesignable class MaskedTextField: UITextField {
  let disposeBag = DisposeBag()
  
  @IBInspectable var formattingPattern: String = ""
  @IBInspectable var replacementChar: String = "*"
  
  var isValid = Variable(false)
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  func configure() {
    rx.text.asDriver().drive(onNext: { [weak self] text in
      guard let formattingPattern = self?.formattingPattern else { return }
      
      if var text = text, text.characters.count > 0, formattingPattern.characters.count > 0 {
        let formattedText = self?.format(text: text)
        
        self?.rx.text.onNext(formattedText)
        self?.isValid.value = formattedText?.characters.count == formattingPattern.characters.count
      }
    }).addDisposableTo(disposeBag)
  }
  
  private func format(text: String) -> String {
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
