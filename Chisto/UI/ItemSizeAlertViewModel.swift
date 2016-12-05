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
  let cancelButtonDidTap = PublishSubject<Void>()
  let dismissViewController: Driver<Void>
  let maxNumberLength = 10
  let squareCentimetersInMeter: Float = 10000
  
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

    let cancelButtonDriver = cancelButtonDidTap.asDriver(onErrorDriveWith: .empty())
    let continueButtonDriver = continueButtonDidTap.asDriver(onErrorDriveWith: .empty())

    self.dismissViewController = Driver.of(cancelButtonDriver, continueButtonDriver).merge()
    
    Observable.combineLatest(lengthText.asObservable(), widthText.asObservable()) { [weak self] lengthText, widthText -> String? in
      guard let lengthText = lengthText, let widthText = widthText, let squareCentimetersInMeter = self?.squareCentimetersInMeter else { return nil }
      guard let length = Float(lengthText.onlyDigits), let width = Float(widthText.onlyDigits) else { return "0 м²" }
      let area = Float(length * width / squareCentimetersInMeter)
      return "\(area) м²"
    }.bindTo(areaText).addDisposableTo(disposeBag)
  }
}
