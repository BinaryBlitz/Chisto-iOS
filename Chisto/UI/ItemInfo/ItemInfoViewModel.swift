//
//  ItemInfoViewModel.swift
//  Chisto
//
//  Created by Алексей on 21.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias ItemInfoSectionModel = SectionModel<String, ItemInfoTableViewCellModelType>

protocol ItemInfoViewModelType {
  // Input
  var addServiceButtonDidTap: PublishSubject<Void> { get }
  var counterIncButtonDidTap: PublishSubject<Void> { get }
  var counterDecButtonDidTap: PublishSubject<Void> { get }
  var tableItemDeleted: PublishSubject<IndexPath> { get }
  var continueButtonDidTap: PublishSubject<Void> { get }
  var navigationCloseButtonDidTap: PublishSubject<Void> { get }

  // Output
  var itemTitle: String { get }
  var itemDescription: String { get }
  var currentAmount: Variable<Int> { get }
  var presentServiceSelectSection: Driver<ServiceSelectViewModel> { get }
  var returnToOrderList: Driver<Void> { get }

  var sections: Driver<[ItemInfoSectionModel]> { get }
}

class ItemInfoViewModel: ItemInfoViewModelType {

  let disposeBag = DisposeBag()

  // Input
  let addServiceButtonDidTap = PublishSubject<Void>()
  let counterIncButtonDidTap = PublishSubject<Void>()
  let counterDecButtonDidTap = PublishSubject<Void>()
  let continueButtonDidTap = PublishSubject<Void>()
  let tableItemDeleted = PublishSubject<IndexPath>()
  let navigationCloseButtonDidTap =  PublishSubject<Void>()

  // Output
  let itemTitle: String
  let itemDescription: String
  var currentAmount: Variable<Int>
  var presentServiceSelectSection: Driver<ServiceSelectViewModel>
  var returnToOrderList: Driver<Void>
  var color: UIColor

  // Constants
  let deleteButtonTitle = "Удалить"

  // Table view
  var sections: Driver<[ItemInfoSectionModel]>
  
  // Data
  let treatments: Variable<[Treatment]>
  
  enum Section: Int {
    case treatments = 0
    case decoration
  }
  
  init(orderItem: OrderItem) {
    let clothesItem = orderItem.clothesItem
    self.itemTitle = clothesItem.name
    self.color = clothesItem.category?.color ?? UIColor.chsSkyBlue
    let currentAmount = Variable<Int>(orderItem.amount)
    self.currentAmount = currentAmount
    
    let hasDecoration = Variable(orderItem.hasDecoration)

    // Subtitle
    self.itemDescription = clothesItem.descriptionText

    // Table view
    let treatments = Variable<[Treatment]>(orderItem.treatments)
    self.treatments = treatments

    self.sections = Driver.combineLatest(treatments.asDriver(), hasDecoration.asDriver()) { treatments, hasDecoration in
      let treatmentsCellModels = treatments.enumerated().map { (index, service) in
        return ItemInfoTableViewCellModel(treatment: service, count: index + 1)
      } as [ItemInfoTableViewCellModelType]
      var sections = [ItemInfoSectionModel(model: "", items: treatmentsCellModels)]

      let decorationCellModel = ItemInfoTableViewCellModel("Декор", "Декоративная отделка", treatments.count + 1) as ItemInfoTableViewCellModelType

      var decorationCellModels: [ItemInfoTableViewCellModelType] = []
      if hasDecoration { decorationCellModels.append(decorationCellModel) }
      let decorationItemInfoSection = ItemInfoSectionModel(model: "", items: decorationCellModels)
      sections.append(decorationItemInfoSection)

      return sections
    }

    self.presentServiceSelectSection = addServiceButtonDidTap.asObservable().map {
      let viewModel = ServiceSelectViewModel(orderItem: orderItem, saveNeeded: false,
          selectedTreatments: treatments.value, hasDecoration: hasDecoration.value)
      viewModel.selectedServices.asObservable().bindTo(treatments).addDisposableTo(viewModel.disposeBag)
      viewModel.hasDecoration.asObservable().bindTo(hasDecoration).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    self.returnToOrderList = Observable.of(navigationCloseButtonDidTap.asObservable(), continueButtonDidTap.asObservable())
      .merge()
      .asDriver(onErrorDriveWith: .empty())

    tableItemDeleted.asObservable().subscribe(onNext: { indexPath in
      switch indexPath.section {
      case Section.decoration.rawValue:
        hasDecoration.value = false
      case Section.treatments.rawValue:
        treatments.value.remove(at: indexPath.row)
      default:
        break
      }
    }).addDisposableTo(disposeBag)

    counterIncButtonDidTap.subscribe(onNext: {
      currentAmount.value += 1
    }).addDisposableTo(disposeBag)

    counterDecButtonDidTap.subscribe(onNext: {
      if currentAmount.value > 1 {
        currentAmount.value -= 1
      }
    }).addDisposableTo(disposeBag)
    
    continueButtonDidTap.asObservable().subscribe(onNext: {
      OrderManager.instance.updateOrderItem(orderItem) {
        orderItem.treatments = treatments.value
        orderItem.amount = currentAmount.value
        orderItem.hasDecoration = hasDecoration.value
      }
    }).addDisposableTo(disposeBag)
  }
  
  func canDeleteItem(at indexPath: IndexPath) -> Bool {
    return indexPath.section == Section.decoration.rawValue || treatments.value.count > 1
  }

}
