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
  let navigationBarTitle = "Мои заказы"
  let orders: Variable<[Order]>
  let tableIsEmpty: Driver<Bool>
  let presentOrderInfoSection: Driver<OrderInfoViewModel>
  
  init() {
    let realmOrders = uiRealm.objects(Order.self).sorted(byProperty: "updatedAt", ascending: true)
    let orders = Variable<[Order]>(realmOrders.toArray())
    self.orders = orders
    
    Observable.from(uiRealm.objects(Order.self))
      .map { Array($0) }
      .bindTo(orders)
      .addDisposableTo(disposeBag)
    
    let fetchOrdersObservable = DataManager.instance.fetchOrders()
    
    self.tableIsEmpty = Driver.combineLatest(orders.asDriver(), fetchOrdersObservable.asDriver(onErrorDriveWith: .empty())) { orders, _ in
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
      return OrderInfoViewModel(order: order)
    }.asDriver(onErrorDriveWith: .empty())
    
  }
}
