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
  let didFinishAlertSuccess = PublishSubject<Void>()
  let dismissViewController: Driver<Bool>
  let maxNumberLength = 6
  let squareCentimetersInMeter: Double = 10000
  
  init(orderItem: OrderItem) {
    let lengthText = Variable<String?>("")
    self.lengthText = lengthText
    let widthText = Variable<String?>("")
    self.widthText = widthText
    self.areaText = Variable<String?>("0 м²")

    if let area = orderItem.size {
      lengthText.value = String(area.length)
      widthText.value = String(area.width)
    }

    areaText.asObservable().map { areaText in
      guard let areaText = areaText else { return false }
      return !areaText.characters.isEmpty
    }.bindTo(continueButtonIsEnabled).addDisposableTo(disposeBag)


    let cancelButtonDriver = cancelButtonDidTap.asDriver(onErrorDriveWith: .empty())
    let continueButtonObservable = continueButtonDidTap.asObservable().map { _ -> (width: Int, length: Int) in
      guard let lengthText = lengthText.value, let widthText = widthText.value else { return ( 0, 0 ) }
      guard let length = Int(lengthText.onlyDigits), let width = Int(widthText.onlyDigits) else { return ( 0, 0 ) }
      return (width: width,length: length)
    }

    let continueButtonDriver = continueButtonObservable.filter { area in
      return area.width * area.length != 0
      }.map { area in
        OrderManager.instance.updateOrderItem(orderItem) {
          orderItem.size = area
        }
    }.asDriver(onErrorDriveWith: .empty())

    self.dismissViewController = Driver.of(cancelButtonDriver.map { false }, continueButtonDriver.map { true } ).merge()

    Observable.combineLatest(lengthText.asObservable(), widthText.asObservable()) { [weak self] lengthText, widthText -> String? in
      self?.area(lengthText: lengthText, widthText: widthText)
    }.bindTo(areaText).addDisposableTo(disposeBag)
  }

  func area(lengthText: String?, widthText: String?) -> String? {
    guard let lengthText = lengthText, let widthText = widthText else { return "0 м²" }
    guard let length = Double(lengthText.onlyDigits), let width = Double(widthText.onlyDigits) else { return "0 м²" }
    let area = Double(length * width / squareCentimetersInMeter).roundTo(places: 1)
    return "\(area) м²"
  }
}
