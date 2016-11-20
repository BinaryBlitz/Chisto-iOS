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
  var sections: Driver<[MyOrdersSectionModel]> { get }
  var navigationBarTitle: String { get }
  var orders: Variable<[Order]> { get }

}

class MyOrdersViewModel: MyOrdersViewModelType {
  let disposeBag = DisposeBag()
  let sections: Driver<[MyOrdersSectionModel]>
  let navigationBarTitle = "Мои заказы"
  let orders: Variable<[Order]>
  
  init() {
    
    let orders = Variable<[Order]>([])
    self.orders = orders
    
    Observable.from(uiRealm.objects(Order.self))
      .map { Array($0).sorted { $0.createdAtDate > $1.createdAtDate } }
      .bindTo(orders)
      .addDisposableTo(disposeBag)

    DataManager.instance.fetchOrders().subscribe().addDisposableTo(disposeBag)
    
    self.sections = orders.asDriver().map { orders in
      let cellModels = orders.map(MyOrdersTableViewCellModel.init) as [MyOrdersTableViewCellModelType]
      
      let section = MyOrdersSectionModel(model: "", items: cellModels)
      return [section]
    }
    
  }
}
