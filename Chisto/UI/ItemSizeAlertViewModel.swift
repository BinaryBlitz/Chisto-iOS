//
//  ItemSizeAlertViewModel.swift
//  Chisto
//
//  Created by Алексей on 04.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ItemSizeAlertViewModel {
  let disposeBag = DisposeBag()
  let lengthText: Variable<String?>
  let widthText: Variable<String?>
  let areaText: Variable<String?>
  let continueButtonIsEnabled = Variable<Bool>(false)
  let continueButtonDidTap = PublishSubject<Void>()
  let dismissViewController: Driver<Void>
  let maxNumberLength = 10
  
  init() {
    let lengthText = Variable<String?>("")
    self.lengthText = lengthText
    let widthText = Variable<String?>("")
    self.widthText = widthText
    self.areaText = Variable<String?>("0 см")
    
    areaText.asObservable().map { areaText in
      guard let areaText = areaText else { return false }
      return !areaText.characters.isEmpty
    }.bindTo(continueButtonIsEnabled).addDisposableTo(disposeBag)
  
    self.dismissViewController = continueButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    Observable.combineLatest(lengthText.asObservable(), widthText.asObservable()) { lengthText, widthText -> String? in
      guard let lengthText = lengthText, let widthText = widthText else { return nil }
      guard let length = Float(lengthText.onlyDigits), let width = Float(widthText.onlyDigits) else { return "0 см" }
      let area = Int(0.5 * length * width)
      return "\(area) см"
    }.bindTo(areaText).addDisposableTo(disposeBag)
  }
}
