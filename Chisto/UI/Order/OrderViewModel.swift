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
  var presentItemConfigurationViewController: Driver<ItemConfigurationViewModel> { get }
  var navigationBarTitle: String { get }
  var footerButtonTitle: String { get }
  var presentLastTimeOrderPopup: PublishSubject<LastTimePopupViewModel> { get }
  var presentLaundrySelectSection: PublishSubject<Void> { get }
  var sections: Driver<[OrderSectionModel]> { get }
  var continueButtonEnabled: Variable<Bool> { get }
}

class OrderViewModel: OrderViewModelType {
  // Input
  var navigationAddButtonDidTap = PublishSubject<Void>()
  var emptyOrderAddButtonDidTap = PublishSubject<Void>()
  var itemDidSelect = PublishSubject<IndexPath>()
  var continueButtonDidTap = PublishSubject<Void>()
  var showAllLaundriesModalButtonDidTap = PublishSubject<Void>()
  var orderButtonDidTap = PublishSubject<Void>()
  let tableItemDeleted = PublishSubject<IndexPath>()

  // Output
  var sections: Driver<[OrderSectionModel]>
  var presentCategoriesViewController: Driver<Void>
  var presentItemConfigurationViewController: Driver<ItemConfigurationViewModel>
  var presentLastTimeOrderPopup = PublishSubject<LastTimePopupViewModel>()
  var presentOrderConfirmSection = PublishSubject<OrderConfirmViewModel>()
  var presentLaundrySelectSection = PublishSubject<Void>()
  var continueButtonEnabled: Variable<Bool>

  // Constants
  let navigationBarTitle = NSLocalizedString("order", comment: "Order screen title")
  let deleteButtonTitle = NSLocalizedString("delete", comment: "Order item delete button title")
  let footerButtonTitle = NSLocalizedString("nothingIsChosenOrderScreen", comment: "No order items placeholder")

  // Data
  let currentOrderItems: Variable<[OrderItem]>

  let disposeBag = DisposeBag()

  init() {
    let continueButtonEnabled = Variable(true)
    self.continueButtonEnabled = continueButtonEnabled

    let currentOrderItems = Variable<[OrderItem]>([])
    OrderManager.instance.currentOrderItems.bind(to: currentOrderItems).addDisposableTo(disposeBag)
    self.currentOrderItems = currentOrderItems

    self.presentCategoriesViewController = Observable.of(navigationAddButtonDidTap.asObservable(), emptyOrderAddButtonDidTap.asObservable()).merge().asDriver(onErrorJustReturn: ())

    self.sections = currentOrderItems.asDriver().map { orderItems in
      let cellModels = orderItems.map(OrderTableViewCellModel.init) as [OrderTableViewCellModelType]

      let section = OrderSectionModel(model: "", items: cellModels)
      return [section]
    }

    showAllLaundriesModalButtonDidTap.bind(to: presentLaundrySelectSection)
      .addDisposableTo(disposeBag)

    let didChooseLaundry = PublishSubject<Laundry>()

    didChooseLaundry.map { OrderConfirmViewModel(laundry: $0) }.bind(to: presentOrderConfirmSection)
      .addDisposableTo(disposeBag)

    self.presentItemConfigurationViewController = itemDidSelect.asObservable().map { indexPath in
      let orderItem = currentOrderItems.value[indexPath.row]
      return ItemConfigurationViewModel(orderItem: orderItem)
    }.asDriver(onErrorDriveWith: .empty())

    let fetchLastOrderDriver = continueButtonDidTap.asDriver(onErrorDriveWith: .empty()).flatMap { _ -> Driver<Void> in
      return DataManager.instance.showUser()
        .asDriver(onErrorDriveWith: .just(())).do(onCompleted: {
          continueButtonEnabled.value = true
        }, onSubscribe: {
          continueButtonEnabled.value = false
        })
    }

    fetchLastOrderDriver.drive(onNext: { [weak self] in
        self?.presentLaundrySelectSection.onNext(())
      }).addDisposableTo(disposeBag)

    tableItemDeleted.asObservable().subscribe(onNext: { indexPath in
        var items = currentOrderItems.value
        items.remove(at: indexPath.row)
        OrderManager.instance.currentOrderItems.onNext(items)
      }).addDisposableTo(disposeBag)

  }
}
