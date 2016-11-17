//
//  NSLayoutConstraint+updateWithKeyboard.swift
//  Chisto
//
//  Created by Алексей on 16.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension NSLayoutConstraint {
  func updateWithKeyboard() {
    let currentConstant = constant
    _ = NotificationCenter.default.rx
      .notification(.UIKeyboardWillShow)
      .takeUntil(self.rx.deallocating)
      .subscribe(onNext: { notification in
      if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        let keyboardHeight = keyboardSize.height
        self.constant = currentConstant + keyboardHeight
      }
    })
    
    _ = NotificationCenter.default.rx
      .notification(.UIKeyboardWillHide)
      .takeUntil(self.rx.deallocating)
      .subscribe(onNext: { _ in
        self.constant = currentConstant
      })
    
    
  }
}
