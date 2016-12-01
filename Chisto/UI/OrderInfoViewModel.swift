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

class OrderInfoViewModel: OrderInfoViewModelType {
  
  let disposeBag = DisposeBag()
  
  // Input
  let supportButtonDidTap = PublishSubject<Void>()
  
  // Output
  var navigationBarTitle: String
  var laundryTitle: String = "Химчистка"
  var laundryDescriprion: String = "Описание химчистки"
  var laundryIcon: URL?  = nil
  var orderNumber: String
  var orderDate: String
  var orderPrice = Variable<String>("...")
  var deliveryPrice = Variable<String>("...")
  var totalCost = Variable<String>("...")
  var orderStatus: String
  var orderStatusIcon: UIImage
  var orderStatusColor: UIColor
  var sections: Driver<[OrderInfoSectionModel]>
  let presentErrorAlert: PublishSubject<Error>
  let presentCallSupportAlert: Driver<Void>
  
  // Data
  let order: Variable<Order>
  let phoneNumber = "+74957667849"
  
  init(order: Order) {
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert
    
    self.presentCallSupportAlert = supportButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    DataManager.instance.fetchOrder(order: order).subscribe(onError: { error in
      presentErrorAlert.onNext(error)
    }).addDisposableTo(disposeBag)
    
    self.navigationBarTitle = "Заказ № \(order.id)"
    self.orderNumber = "№ \(order.id)"
    self.orderDate = order.createdAt.mediumDate
    self.orderStatus = order.status.description
    self.orderStatusIcon = order.status.image
    self.orderStatusColor = order.status.color
    
    let order = Variable<Order>(order)
    self.order = order
    
    let orderLineItemsObservable = order.asObservable().map { $0.lineItems.toArray() }
    
    let groupedLineItemsObservable = orderLineItemsObservable.map { items in
      items.categorize { $0.lineItemInfo }
    }
    
    self.sections = groupedLineItemsObservable.map { lineItemDictionary in
      let cellModels = lineItemDictionary.map(OrderInfoTableViewCellModel.init) as [OrderInfoTableViewCellModelType]
      return [OrderInfoSectionModel(model: "", items: cellModels)]
    }.asDriver(onErrorDriveWith: .empty())
    
    order.asObservable().map { order in
      return order.deliveryPriceString
    }.bindTo(deliveryPrice).addDisposableTo(disposeBag)
    
    order.asObservable().map { order in
      return "\(order.price) ₽"
    }.bindTo(orderPrice).addDisposableTo(disposeBag)
    
    order.asObservable().map { order in
      return "\(order.price + order.deliveryPrice) ₽"
    }.bindTo(totalCost).addDisposableTo(disposeBag)
    
    uiRealm.observableObject(type: Order.self, primaryKey: order.value.id)
      .filter{ $0 != nil}
      .map { $0! }
      .bindTo(order)
      .addDisposableTo(disposeBag)
      
    guard let laundry = uiRealm.object(ofType: Laundry.self, forPrimaryKey: order.value.laundryId) else { return }
    self.laundryTitle = laundry.name
    self.laundryDescriprion = laundry.descriptionText
    self.laundryIcon = URL(string: laundry.logoUrl)
  }
  
}
