//
//  ItemConfigurationViewModel.swift
//  Chisto
//
//  Created by Алексей on 29.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class ItemConfigurationViewModel {
  let maxNumberLength = 6
  let squareCentimetersInMeter: Double = 10000
  let disposeBag = DisposeBag()

  // Input
  var saveButtonTapped = PublishSubject<Void>()
  let counterIncButtonTapped = PublishSubject<Void>()
  let counterDecButtonTapped = PublishSubject<Void>()

  // Output
  var color: UIColor
  var itemTitle: String
  var itemDescription: String
  var useArea: Bool

  let dismiss = PublishSubject<Void>()
  let lengthText: Variable<String?>
  let widthText: Variable<String?>
  let areaText: Variable<String?>

  let saveButtonIsEnabled = Variable<Bool>(false)

  // Data
  var orderItem: OrderItem
  var currentAmount: Variable<Int>
  var hasDecoration = Variable<Bool>(false)

  init(orderItem: OrderItem,
       hasDecoration: Bool = false) {

    let currentAmount = Variable<Int>(orderItem.amount)
    self.currentAmount = currentAmount

    let lengthText = Variable<String?>("")
    self.lengthText = lengthText
    let widthText = Variable<String?>("")
    self.widthText = widthText
    self.areaText = Variable<String?>("0 м²")

    if let area = orderItem.size {
      lengthText.value = String(area.length)
      widthText.value = String(area.width)
    }

    self.orderItem = orderItem

    let item = orderItem.clothesItem

    self.itemTitle = item.name
    self.itemDescription = item.descriptionText
    self.color = item.category?.color ?? UIColor.chsSkyBlue
    self.useArea = item.useArea

    saveButtonTapped
      .map { self.save() }
      .bind(to: dismiss)
      .addDisposableTo(disposeBag)

    areaText.asObservable().map { areaText in
      guard orderItem.clothesItem.useArea else { return true }
      guard let areaText = areaText else { return false }
      return !areaText.characters.isEmpty
    }.bind(to: saveButtonIsEnabled).addDisposableTo(disposeBag)

    Observable.combineLatest(lengthText.asObservable(), widthText.asObservable()) { [weak self] lengthText, widthText -> String? in
      self?.area(lengthText: lengthText, widthText: widthText)
    }.bind(to: areaText).addDisposableTo(disposeBag)

    counterIncButtonTapped.subscribe(onNext: {
      currentAmount.value += 1
    }).addDisposableTo(disposeBag)

    counterDecButtonTapped.subscribe(onNext: {
      if currentAmount.value > 1 {
        currentAmount.value -= 1
      }
    }).addDisposableTo(disposeBag)

  }

  func area(lengthText: String?, widthText: String?) -> String? {
    guard let lengthText = lengthText, let widthText = widthText else { return "0 м²" }
    guard let length = Double(lengthText.onlyDigits), let width = Double(widthText.onlyDigits) else { return "0 м²" }
    let area = Double(length * width / squareCentimetersInMeter).roundTo(places: 1)
    return "\(area) м²"
  }

  func size() -> (width: Int, length: Int) {
    guard let lengthText = lengthText.value, let widthText = widthText.value else { return (0, 0) }
    guard let length = Int(lengthText.onlyDigits), let width = Int(widthText.onlyDigits) else { return (0, 0) }
    return (width: width, length: length)
  }

  func save() {
    OrderManager.instance.updateOrderItem(orderItem) {
      orderItem.hasDecoration = hasDecoration.value
      orderItem.size = size()
    }
  }

}
