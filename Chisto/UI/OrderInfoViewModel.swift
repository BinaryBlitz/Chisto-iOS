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
  var laundryTitle: String { get }
  var laundryDescriprion: String { get }
  var laundryIcon: URL? { get }
  var orderNumber: String { get }
  var orderPrice: Variable<String> { get }
  var deliveryPrice: Variable<String>  { get }
  var totalCost: Variable<String>  { get }
  var orderDate: String { get }
  var orderStatus: String { get }
  var orderStatusIcon: UIImage { get }
  var orderStatusColor: UIColor { get }
  var sections: Driver<[OrderInfoSectionModel]> { get }
}

class OrderInfoViewModel {
  
  let disposeBag = DisposeBag()
  
  // Input
  let supportButtonDidTap = PublishSubject<Void>()
  
  // Output
  var navigationBarTitle: String
  var laundryTitle = Variable<String?>("Химчистка")
  var laundryDescriprion = Variable<String?>("Описание химчистки")
  var laundryIcon = Variable<URL?>(nil)
  var orderNumber: String = ""
  var orderDate = Variable<String>("")
  var orderPrice = Variable<String>("...")
  var deliveryPrice = Variable<String>("...")
  var totalCost = Variable<String>("...")
  var orderStatus = Variable<String>("")
  var orderStatusIcon = Variable<UIImage?>(nil)
  var orderStatusColor = Variable<UIColor>(.chsSkyBlue)
  var sections: Driver<[OrderInfoSectionModel]>
  let presentErrorAlert: PublishSubject<Error>
  let presentCallSupportAlert: Driver<Void>
  
  // Data
  let order: Variable<Order?>
  let phoneNumber = "+7 495 766-78-49"
  
  init(orderId: Int) {
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert
    let order = Variable<Order?>(nil)
    let realm = RealmManager.instance.uiRealm
    if let orderObject = realm.object(ofType: Order.self, forPrimaryKey: orderId) { order.value = orderObject }
    self.presentCallSupportAlert = supportButtonDidTap.asDriver(onErrorDriveWith: .empty())

    self.navigationBarTitle = "Заказ № \(orderId)"
    self.orderNumber = "№ \(orderId)"
    let observableOrder = order.asObservable().filter { $0 != nil }.map { $0! }
    observableOrder.map { $0.createdAt.mediumDate }.bindTo(self.orderDate).addDisposableTo(disposeBag)
    observableOrder.map { $0.status.description }.bindTo(self.orderStatus).addDisposableTo(disposeBag)
    observableOrder.map { $0.status.image }.bindTo(self.orderStatusIcon).addDisposableTo(disposeBag)
    observableOrder.map { $0.status.color }.bindTo(self.orderStatusColor).addDisposableTo(disposeBag)
    
    self.order = order

    DataManager.instance.getOrderInfo(orderId: orderId).bindTo(order).addDisposableTo(disposeBag)

    let orderLineItemsObservable = observableOrder.map { $0.lineItems }
    
    self.sections = orderLineItemsObservable.map { orderLineItems in
      let cellModels = orderLineItems.map(OrderInfoTableViewCellModel.init) as [OrderInfoTableViewCellModelType]
      return [OrderInfoSectionModel(model: "", items: cellModels)]
    }.asDriver(onErrorDriveWith: .empty())
    
    observableOrder.map { $0.deliveryPriceString }.bindTo(deliveryPrice).addDisposableTo(disposeBag)
    observableOrder.map { $0.orderPrice.currencyString }.bindTo(orderPrice).addDisposableTo(disposeBag)
    observableOrder.map { $0.totalPrice.currencyString }.bindTo(totalCost).addDisposableTo(disposeBag)

    let observableOrderLaundry = observableOrder.map { realm.object(ofType: Laundry.self, forPrimaryKey: $0.laundryId ) }
    observableOrderLaundry.map { $0?.name }.bindTo(laundryTitle).addDisposableTo(disposeBag)
    observableOrderLaundry.map { $0?.descriptionText }.bindTo(laundryDescriprion).addDisposableTo(disposeBag)
    observableOrderLaundry.map { URL(string: $0?.logoUrl ?? "") }.bindTo(laundryIcon).addDisposableTo(disposeBag)
  }
  
}
