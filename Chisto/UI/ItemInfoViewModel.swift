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
  
  // Output
  var itemTitle: String { get }
  var itemRelatedText: NSAttributedString { get }
  var currentAmount: Variable<Int> { get }
  var presentServiceSelectSection: Driver<ServiceSelectViewModel> { get }
  var returnToOrderList: Driver<Void> { get }
  
  var sections: Driver<[ItemInfoSectionModel]> { get }
}

class ItemInfoViewModel: ItemInfoViewModelType {
  let disposeBag = DisposeBag()
  
  // Input
  var addServiceButtonDidTap = PublishSubject<Void>()
  var counterIncButtonDidTap = PublishSubject<Void>()
  var counterDecButtonDidTap = PublishSubject<Void>()
  var continueButtonDidTap = PublishSubject<Void>()
  var tableItemDeleted = PublishSubject<IndexPath>()
  
  // Output
  let itemTitle: String
  let itemRelatedText: NSAttributedString
  var currentAmount: Variable<Int>
  var presentServiceSelectSection: Driver<ServiceSelectViewModel>
  var returnToOrderList: Driver<Void>
  var color: UIColor
  
  // Constants
  let deleteButtonTitle = "Удалить"
  
  // Table view
  var sections: Driver<[ItemInfoSectionModel]>

  init(orderItem: OrderItem) {
    self.itemTitle = orderItem.clothesItem.name
    // TODO: get a color from item model
    //self.color = orderItem.clothesItem.color
    self.color = UIColor.chsSkyBlue
    let currentAmount = Variable<Int>(orderItem.amount)
    self.currentAmount = currentAmount

    // Subtitle
    let relatedItemsAttrString = NSMutableAttributedString()
    
    self.itemRelatedText = relatedItemsAttrString

    // Table view
    let treatments = Variable<[Treatment]>(orderItem.treatments)
    
    self.sections = treatments.asDriver().map { treatments in
      let cellModels = treatments.enumerated().map { (index, service) in
        ItemInfoTableViewCellModel(treatment: service, count: index)
      } as [ItemInfoTableViewCellModelType]
      
      let section = ItemInfoSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.presentServiceSelectSection = addServiceButtonDidTap.asObservable().map {
      let viewModel = ServiceSelectViewModel(item: orderItem, saveNeeded: false, selectedTreatments: treatments.value)
      viewModel.selectedServices.asObservable().bindTo(treatments).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())
    
    self.returnToOrderList = continueButtonDidTap.asObservable().map {
      OrderManager.instance.updateOrderItem(item: orderItem) {
        orderItem.treatments = treatments.value
        orderItem.amount = currentAmount.value
      }
    }.asDriver(onErrorDriveWith: .empty())
    
    tableItemDeleted.asObservable().subscribe(onNext: { indexPath in
      treatments.value.remove(at: indexPath.row)
    }).addDisposableTo(disposeBag)
    
    counterIncButtonDidTap.subscribe(onNext: {
      currentAmount.value += 1
    }).addDisposableTo(disposeBag)
    
    counterDecButtonDidTap.subscribe(onNext: {
      if currentAmount.value > 1 {
        currentAmount.value -= 1
      }
    }).addDisposableTo(disposeBag)
    
    
  }
}
