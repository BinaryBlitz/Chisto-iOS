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
  var profileButtonDidTap: PublishSubject<Void> { get }

  // Output
  var presentCategoriesViewController: Driver<Void> { get }
  var presentItemInfoViewController: Driver<ItemInfoViewModel> { get }
  var navigationBarTitle: String { get }
  var footerButtonTitle: String { get }
  var presentLastTimeOrderPopup: PublishSubject<LastTimePopupViewModel> { get }
  var presentLaundrySelectSection: PublishSubject<Void> { get }
  var sections: Driver<[OrderSectionModel]> { get }
}

class OrderViewModel: OrderViewModelType {
  // Input
  var navigationAddButtonDidTap = PublishSubject<Void>()
  var emptyOrderAddButtonDidTap = PublishSubject<Void>()
  var itemDidSelect = PublishSubject<IndexPath>()
  var continueButtonDidTap = PublishSubject<Void>()
  var showAllLaundriesModalButtonDidTap = PublishSubject<Void>()
  var profileButtonDidTap = PublishSubject<Void>()

  // Output
  var sections: Driver<[OrderSectionModel]>
  var presentCategoriesViewController: Driver<Void>
  var presentItemInfoViewController: Driver<ItemInfoViewModel>
  var presentLastTimeOrderPopup = PublishSubject<LastTimePopupViewModel>()
  var presentLaundrySelectSection = PublishSubject<Void>()
  var presentProfileSection: Driver<Void>

  // Constants
  let navigationBarTitle = "Заказ"
  let footerButtonTitle = "Ничего не выбрано"

  // Data
  let currentOrderItems: Variable<[OrderItem]>

  let disposeBag = DisposeBag()

  init() {
    let currentOrderItems = Variable<[OrderItem]>([])
    OrderManager.instance.currentOrderItems.bindTo(currentOrderItems).addDisposableTo(disposeBag)
    self.currentOrderItems = currentOrderItems

    self.presentCategoriesViewController = Observable.of(navigationAddButtonDidTap.asObservable(), emptyOrderAddButtonDidTap.asObservable()).merge().asDriver(onErrorJustReturn: ())

    self.sections = currentOrderItems.asDriver().map { orderItems in
      let cellModels = orderItems.map(OrderTableViewCellModel.init) as [OrderTableViewCellModelType]

      let section = OrderSectionModel(model: "", items: cellModels)
      return [section]
    }

    showAllLaundriesModalButtonDidTap.bindTo(presentLaundrySelectSection)
      .addDisposableTo(disposeBag)

    self.presentItemInfoViewController = itemDidSelect.asObservable().map { indexPath in
      let orderItem = currentOrderItems.value[indexPath.row]
      return ItemInfoViewModel(orderItem: orderItem)
    }.asDriver(onErrorDriveWith: .empty())
    
    self.presentProfileSection = profileButtonDidTap.asDriver(onErrorDriveWith: .empty())

    continueButtonDidTap.asDriver(onErrorDriveWith: .empty()).drive(onNext: {
      // TODO: Change this logic to correct one(as soon as it is ready on backend)
      if let laundry = uiRealm.objects(Laundry.self).first {
        let viewModel = LastTimePopupViewModel(laundry: laundry)
        self.presentLastTimeOrderPopup.onNext(viewModel)
      } else {
        self.presentLaundrySelectSection.onNext()
      }
    }).addDisposableTo(disposeBag)

  }
}
