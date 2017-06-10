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

private let treatmentViewHeight: Double = 60.5

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

  var treatments: Variable<[Treatment]>

  let saveButtonIsEnabled = Variable<Bool>(false)

  // Data
  let orderItem: OrderItem
  let currentAmount: Variable<Int>
  let hasDecoration: Variable<Bool>
  let currentMaterial: Variable<Treatment?>

  var treatmentRowHeight: Double {
    guard !treatments.value.isEmpty else { return 0.01 }
    return Double(treatments.value.count) * treatmentViewHeight
  }

  init(orderItem: OrderItem) {

    let currentAmount = Variable<Int>(orderItem.amount)
    self.currentAmount = currentAmount

    let currentMaterial = Variable<Treatment?>(orderItem.treatments.first)
    self.currentMaterial = currentMaterial

    self.hasDecoration = Variable(orderItem.hasDecoration)

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

    DataManager.instance.fetchClothesTreatments(item: item).subscribe().addDisposableTo(disposeBag)
    let treatments = Variable<[Treatment]>([])
    Observable.collection(from: item.treatments.filter("isDeleted == %@", false).sorted(byKeyPath: "name"))
      .map { Array($0) }
      .bind(to: treatments)
      .addDisposableTo(disposeBag)
    self.treatments = treatments

    saveButtonTapped
      .map { self.save() }
      .bind(to: dismiss)
      .addDisposableTo(disposeBag)

    Observable.combineLatest(currentMaterial.asObservable(), areaText.asObservable()) { treatment, areaText in
      guard treatment != nil else { return false }
      guard orderItem.clothesItem.useArea else { return true }
      let areaText = areaText ?? ""
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
    guard let lengthText = lengthText,
          let widthText = widthText else { return "0 м²" }
    guard let length = Double(lengthText.onlyDigits),
          let width = Double(widthText.onlyDigits) else { return "0 м²" }
    let area = Double(length * width / squareCentimetersInMeter).roundTo(places: 1)
    return "\(area) м²"
  }

  func size() -> (width: Int, length: Int)? {
    guard orderItem.clothesItem.useArea else { return nil }
    guard let lengthText = lengthText.value, let widthText = widthText.value else { return (0, 0) }
    guard let length = Int(lengthText.onlyDigits), let width = Int(widthText.onlyDigits) else { return (0, 0) }
    return (width: width, length: length)
  }

  func save() {
    OrderManager.instance.updateOrderItem(orderItem) {
      orderItem.hasDecoration = hasDecoration.value
      orderItem.size = size()
      if let treatment = currentMaterial.value {
        orderItem.treatments = [treatment]
      }
      orderItem.amount = currentAmount.value
    }
  }

}
