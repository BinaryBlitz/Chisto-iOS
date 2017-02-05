//
//  OrderInfoViewModel.swift
//  Chisto
//
//  Created by Алексей on 20.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import UIKit
import RealmSwift

typealias OrderInfoSectionModel = SectionModel<String, OrderInfoTableViewCellModelType>

protocol OrderInfoViewModelType {
  // Input
  var supportButtonDidTap: PublishSubject<Void> { get }
  
  // Output
  var navigationBarTitle: String { get }
  var sections: Driver<[OrderInfoSectionModel]> { get }
}

class OrderInfoViewModel {
  
  let disposeBag = DisposeBag()
  
  // Input
  let ratingButtonDidTap = PublishSubject<Void>()
  
  // Output
  var navigationBarTitle: String
  var sections: Driver<[OrderInfoSectionModel]>
  let presentErrorAlert: PublishSubject<Error>
  let presentRatingAlert: Driver<OrderReviewAlertViewModel>
  let orderInfoTableHeaderViewModel: OrderInfoTableHeaderViewModel
  let ratingButtonEnabled = Variable<Bool>(false)
  
  // Data
  let order: Variable<Order?>
  let phoneNumber = "+7 495 766-78-49"
  
  init(orderId: Int) {
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert
    let order = Variable<Order?>(nil)
    let realm = RealmManager.instance.uiRealm
    if let orderObject = realm.object(ofType: Order.self, forPrimaryKey: orderId) { order.value = orderObject }

    self.navigationBarTitle = String(format: NSLocalizedString("orderNumber", comment: "Order info screen title"), String(orderId))
    let observableOrder = order.asObservable().filter { $0 != nil }.map { $0! }

    self.orderInfoTableHeaderViewModel = OrderInfoTableHeaderViewModel(order: observableOrder)

    self.order = order

    DataManager.instance.getOrderInfo(orderId: orderId).bindTo(order).addDisposableTo(disposeBag)

    let orderLineItemsObservable = observableOrder.map { $0.lineItems }

    observableOrder.map { $0.status == .completed }.bindTo(ratingButtonEnabled).addDisposableTo(disposeBag)
    
    self.sections = orderLineItemsObservable.map { orderLineItems in
      let cellModels = orderLineItems.map(OrderInfoTableViewCellModel.init) as [OrderInfoTableViewCellModelType]
      return [OrderInfoSectionModel(model: "", items: cellModels)]
    }.asDriver(onErrorDriveWith: .empty())

    let shouldRateOrderObservable = DataManager.instance.showUser()
      .map { ProfileManager.instance.userProfile.value.order }.filter { order in
        guard let order = order else { return false }
        return order.id == orderId && order.rating == nil
    }

    let ratingButtonTappedDriver = ratingButtonDidTap
      .asDriver(onErrorDriveWith: .empty())
      .filter { order.value != nil }.map { order.value }

    presentRatingAlert = Driver.of(shouldRateOrderObservable.asDriver(onErrorDriveWith: .empty()), ratingButtonTappedDriver).merge().map { OrderReviewAlertViewModel(order: $0!) }

  }
  
}
