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
  var profileButtonDidTap = PublishSubject<Void>()
  let tableItemDeleted = PublishSubject<IndexPath>()

  // Output
  var sections: Driver<[OrderSectionModel]>
  var presentCategoriesViewController: Driver<Void>
  var presentItemInfoViewController: Driver<ItemInfoViewModel>
  var presentLastTimeOrderPopup = PublishSubject<LastTimePopupViewModel>()
  var presentOrderConfirmSection = PublishSubject<OrderConfirmViewModel>()
  var presentLaundrySelectSection = PublishSubject<Void>()
  var presentProfileSection: Driver<Void>
  var presentRatingSection: Driver<OrderReviewAlertViewModel>
  var continueButtonEnabled: Variable<Bool>

  // Constants
  let navigationBarTitle = NSLocalizedString("order", comment: "Order screen title")
  let deleteButtonTitle = NSLocalizedString("delete", comment: "Order item delete button title")
  let footerButtonTitle = NSLocalizedString("nothingIsChosen", comment: "No orders placeholder")

  // Data
  let currentOrderItems: Variable<[OrderItem]>

  let disposeBag = DisposeBag()

  init() {
    let continueButtonEnabled = Variable(true)
    self.continueButtonEnabled = continueButtonEnabled

    let fetchLastOrder = DataManager.instance.showUser().map { ProfileManager.instance.userProfile.value.order }

    self.presentRatingSection = fetchLastOrder
      .filter { order in
        guard let order = order else { return false }
        return order.status == .completed && order.rating == nil && order.ratingRequired
      }.map { order in
      return OrderReviewAlertViewModel(order: order!)
    }.asDriver(onErrorDriveWith: .empty())
    
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

    let didChooseLaundry = PublishSubject<Laundry>()

    didChooseLaundry.map { OrderConfirmViewModel(laundry: $0) }.bindTo(presentOrderConfirmSection)
      .addDisposableTo(disposeBag)

    self.presentItemInfoViewController = itemDidSelect.asObservable().map { indexPath in
      let orderItem = currentOrderItems.value[indexPath.row]
      return ItemInfoViewModel(orderItem: orderItem)
    }.asDriver(onErrorDriveWith: .empty())
    
    self.presentProfileSection = profileButtonDidTap.asDriver(onErrorDriveWith: .empty())

    let fetchLastOrderDriver = continueButtonDidTap.asDriver(onErrorDriveWith: .empty()).flatMap { _ -> Driver<Void> in
      return DataManager.instance.showUser()
        .asDriver(onErrorDriveWith: .just()).do(onCompleted: {
          continueButtonEnabled.value = true
        }, onSubscribe: {
          continueButtonEnabled.value = false
        })
    }

    fetchLastOrderDriver.drive(onNext: { [weak self] in
      self?.presentLaundrySelectSection.onNext()
    }).addDisposableTo(disposeBag)
    
    tableItemDeleted.asObservable().subscribe(onNext: { indexPath in
      var items = currentOrderItems.value
      items.remove(at: indexPath.row)
      OrderManager.instance.currentOrderItems.onNext(items)
    }).addDisposableTo(disposeBag)

  }
}
