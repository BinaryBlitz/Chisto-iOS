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
    configureMaskedField()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureMaskedField()
  }
  
  func configureMaskedField() {
    rx.text.asDriver().drive(onNext: { [weak self] text in
      guard let formattingPattern = self?.formattingPattern else { return }
      guard let replacementChar = self?.replacementChar else { return }
      
      if var text = text, text.characters.count > 0, formattingPattern.characters.count > 0 {
        let tempString = text.onlyDigits
        
        var finalText = ""
        
        var formatterIndex = formattingPattern.startIndex
        var tempIndex = tempString.startIndex
        
        while !(formatterIndex >= formattingPattern.endIndex || tempIndex >= tempString.endIndex) {
          let formattingPatternRange = formatterIndex ..< formattingPattern.index(formatterIndex, offsetBy: 1)
          
          if formattingPattern.substring(with: formattingPatternRange) != replacementChar {
            finalText = finalText + formattingPattern.substring(with: formattingPatternRange)
          } else if tempString.characters.count > 0 {
            let pureStringRange = tempIndex ..< tempString.index(tempIndex, offsetBy: 1)
            finalText = finalText + tempString.substring(with: pureStringRange)
            tempIndex = tempString.index(after: tempIndex)
          }
          formatterIndex = formattingPattern.index(after: formatterIndex)
          
        }
        
        self?.rx.text.onNext(finalText)
        self?.isValid.value = finalText.characters.count == formattingPattern.characters.count
      }
      }).addDisposableTo(disposeBag)
  }

}
