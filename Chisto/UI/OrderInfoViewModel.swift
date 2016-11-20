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
  var orderPrice: String { get }
  var deliveryPrice: String { get }
  var totalCost: String { get }
  var orderDate: String { get }
  var orderStatus: String { get }
  var orderStatusIcon: UIImage { get }
  var orderStatusColor: UIColor { get }
  //var sections: Driver<[OrderInfoSectionModel]> { get }
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
  var orderPrice: String = "Бесплатно"
  var deliveryPrice: String = "Бесплатно"
  var totalCost: String = "Бесплатно"
  var orderStatus: String
  var orderStatusIcon: UIImage
  var orderStatusColor: UIColor
  //var sections: Driver<[OrderConfirmSectionModel]>
  
  init(order: Order) {
    self.navigationBarTitle = "Заказ № \(order.id)"
    self.orderNumber = "№ \(order.id)"
    self.orderDate = order.createdAtDate.mediumDate
    self.orderStatus = order.status.description
    self.orderStatusIcon = order.status.image
    self.orderStatusColor = order.status.color
    
    guard let laundry = uiRealm.object(ofType: Laundry.self, forPrimaryKey: order.laundryId) else { return }
    self.laundryTitle = laundry.name
    self.laundryDescriprion = laundry.descriptionText
    self.laundryIcon = URL(string: laundry.logoUrl)
  }
  
}
