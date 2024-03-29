//
//  MyOrdersViewModel.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

typealias MyOrdersSectionModel = SectionModel<String, MyOrdersTableViewCellModelType>

protocol MyOrdersViewModelType {
  var itemDidSelect: PublishSubject<IndexPath> { get }

  var sections: Driver<[MyOrdersSectionModel]> { get }
  var navigationBarTitle: String { get }
  var orders: Variable<[Order]> { get }
  var presentOrderInfoSection: Driver<OrderInfoViewModel> { get }

}

class MyOrdersViewModel: MyOrdersViewModelType {
  let disposeBag = DisposeBag()

  let itemDidSelect = PublishSubject<IndexPath>()
  let sections: Driver<[MyOrdersSectionModel]>
  let navigationBarTitle = NSLocalizedString("myOrders", comment: "My orders screen")
  let orders: Variable<[Order]>
  let tableIsEmpty: Driver<Bool>
  let presentOrderInfoSection: Driver<OrderInfoViewModel>

  init() {
    let realmOrders = RealmManager.instance.uiRealm.objects(Order.self)
      .filter("isDeleted == %@", false)
      .sorted(byKeyPath: "updatedAt", ascending: false)

    let orders = Variable<[Order]>(realmOrders.toArray())
    self.orders = orders

    Observable.collection(from: realmOrders)
      .map { Array($0) }
      .bind(to: orders)
      .addDisposableTo(disposeBag)

    let fetchOrdersObservable = DataManager.instance.fetchOrders()

    self.tableIsEmpty = Driver.combineLatest(orders.asDriver(), fetchOrdersObservable.asDriver(onErrorDriveWith: Driver.just(()))) { orders, _ in
      return orders.isEmpty
    }

    fetchOrdersObservable.subscribe().addDisposableTo(disposeBag)

    self.sections = orders.asDriver().map { orders in
      let cellModels = orders.map(MyOrdersTableViewCellModel.init) as [MyOrdersTableViewCellModelType]

      let section = MyOrdersSectionModel(model: "", items: cellModels)
      return [section]
    }

    self.presentOrderInfoSection = itemDidSelect.map { indexPath in
      let order = orders.value[indexPath.row]
      return OrderInfoViewModel(orderId: order.id)
    }.asDriver(onErrorDriveWith: .empty())

  }
}
