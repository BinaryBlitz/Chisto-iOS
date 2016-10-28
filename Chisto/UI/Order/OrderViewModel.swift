//
//  OrderViewModel.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

typealias OrderSectionModel = SectionModel<String, OrderTableViewCellModelType>


protocol OrderViewModelType {
  // Input
  var navigationAddButtonDidTap: PublishSubject<Void> { get }
  var emptyOrderAddButtonDidTap: PublishSubject<Void> { get }
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var continueButtonDidTap: PublishSubject<Void> { get }
  
  // Output
  var presentCategoriesViewController: Driver<Void> { get }
  var presentItemInfoViewController: Driver<ItemInfoViewModel> { get }
  var navigationBarTitle: String { get }
  var footerButtonTitle: String { get }
  var presentLastTimeOrderPopup: Driver<LastTimePopupViewModel> { get }
  var presentLaundrySelectSection: Driver<Void> { get }
  var sections: Driver<[OrderSectionModel]> { get }
}

class OrderViewModel: OrderViewModelType {
  // Input
  var navigationAddButtonDidTap = PublishSubject<Void>()
  var emptyOrderAddButtonDidTap = PublishSubject<Void>()
  var itemDidSelect = PublishSubject<IndexPath>()
  var continueButtonDidTap = PublishSubject<Void>()
  var showAllLaundriesModalButtonDidTap = PublishSubject<Void>()
  
  // Output
  var sections: Driver<[OrderSectionModel]>
  var presentCategoriesViewController: Driver<Void>
  var presentItemInfoViewController: Driver<ItemInfoViewModel>
  var presentLastTimeOrderPopup: Driver<LastTimePopupViewModel>
  var presentLaundrySelectSection: Driver<Void>
  
  // Constants
  let navigationBarTitle = "Заказ"
  let footerButtonTitle = "Ничего не выбрано"
  
  // Data
  let currentOrderItems: Variable<[OrderItem]>
  
  init() {
    let currentOrderItems = DataManager.instance.currentOrderItems
    self.currentOrderItems = currentOrderItems

    self.presentCategoriesViewController = Observable.of(navigationAddButtonDidTap.asObservable(), emptyOrderAddButtonDidTap.asObservable()).merge().asDriver(onErrorJustReturn: ())
    
    self.presentItemInfoViewController = itemDidSelect.asObservable().map { indexPath in
      let orderItem = currentOrderItems.value[indexPath.row]
      return ItemInfoViewModel(orderItem: orderItem)
    }.asDriver(onErrorDriveWith: .empty())
    
    self.sections = currentOrderItems.asDriver().map { orderItems in
      let cellModels = orderItems.map(OrderTableViewCellModel.init) as [OrderTableViewCellModelType]
      
      let section = OrderSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.presentLaundrySelectSection = showAllLaundriesModalButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    self.presentLastTimeOrderPopup = continueButtonDidTap.asObservable().map {
      LastTimePopupViewModel()
    }.asDriver(onErrorDriveWith: .empty())
    
  }
}
