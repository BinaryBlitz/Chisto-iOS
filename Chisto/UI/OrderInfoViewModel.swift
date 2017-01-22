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
  
  // Data
  let order: Variable<Order?>
  let phoneNumber = "+7 495 766-78-49"
  
  init(orderId: Int) {
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert
    let order = Variable<Order?>(nil)
    let realm = RealmManager.instance.uiRealm
    if let orderObject = realm.object(ofType: Order.self, forPrimaryKey: orderId) { order.value = orderObject }
    self.presentRatingAlert = ratingButtonDidTap
      .asDriver(onErrorDriveWith: .empty())
      .filter { order.value != nil }.map { OrderReviewAlertViewModel(order: order.value!) }

    self.navigationBarTitle = "Заказ № \(orderId)"
    let observableOrder = order.asObservable().filter { $0 != nil }.map { $0! }

    self.orderInfoTableHeaderViewModel = OrderInfoTableHeaderViewModel(order: observableOrder)

    self.order = order

    DataManager.instance.getOrderInfo(orderId: orderId).bindTo(order).addDisposableTo(disposeBag)

    let orderLineItemsObservable = observableOrder.map { $0.lineItems }
    
    self.sections = orderLineItemsObservable.map { orderLineItems in
      let cellModels = orderLineItems.map(OrderInfoTableViewCellModel.init) as [OrderInfoTableViewCellModelType]
      return [OrderInfoSectionModel(model: "", items: cellModels)]
    }.asDriver(onErrorDriveWith: .empty())
  }
  
}
