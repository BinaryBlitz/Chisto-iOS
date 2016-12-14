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
  let squareCentimetersInMeter: Double = 10000
  
  init(orderItem: OrderItem) {
    let lengthText = Variable<String?>("")
    self.lengthText = lengthText
    let widthText = Variable<String?>("")
    self.widthText = widthText
    self.areaText = Variable<String?>("0 м²")

    if let area = orderItem.area {
      lengthText.value = String(area.length)
      widthText.value = String(area.width)
    }

    areaText.asObservable().map { areaText in
      guard let areaText = areaText else { return false }
      return !areaText.characters.isEmpty
    }.bindTo(continueButtonIsEnabled).addDisposableTo(disposeBag)


    let cancelButtonDriver = cancelButtonDidTap.asDriver(onErrorDriveWith: .empty())
    let continueButtonDriver = continueButtonDidTap.asDriver(onErrorDriveWith: .empty()).do(onNext: {_ in
      guard let lengthText = lengthText.value, let widthText = widthText.value else { return }
      guard let length = Int(lengthText.onlyDigits), let width = Int(widthText.onlyDigits) else { return }
      OrderManager.instance.updateOrderItem(orderItem) {
        orderItem.area = (width, length)
      }
    })

    self.dismissViewController = Driver.of(cancelButtonDriver, continueButtonDriver).merge()

    Observable.combineLatest(lengthText.asObservable(), widthText.asObservable()) { [weak self] lengthText, widthText -> String? in
      self?.area(lengthText: lengthText, widthText: widthText)
    }.bindTo(areaText).addDisposableTo(disposeBag)
  }

  func area(lengthText: String?, widthText: String?) -> String? {
    guard let lengthText = lengthText, let widthText = widthText else { return "0 м²" }
    guard let length = Double(lengthText.onlyDigits), let width = Double(widthText.onlyDigits) else { return "0 м²" }
    let area = Double(length * width / squareCentimetersInMeter) as NSNumber
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumIntegerDigits = 1
    numberFormatter.maximumFractionDigits = 5
    guard let areaString = numberFormatter.string(from: area) else { return "0 м²" }
    return "\(areaString) м²"
  }
}
