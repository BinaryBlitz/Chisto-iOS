//
//  OrderConfirmViewModel.swift
//  Chisto
//
//  Created by Алексей on 02.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import UIKit

typealias OrderConfirmSectionModel = SectionModel<String, OrderConfirmServiceTableViewCellModelType>

protocol OrderConfirmViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var confirmOrderButtonDidTap: PublishSubject<Void> { get }
  
  // Output
  var navigationBarTitle: String { get }
  var laundryDescriprionTitle: String { get }
  var laundryRating: Float { get }
  var courierDate: String { get }
  var deliveryDate: String { get }
  var laundryIcon: UIImage? { get }
  var sections: Driver<[OrderConfirmSectionModel]> { get }
  var presentRegistrationSection: Driver<Void> { get }
  
}

class OrderConfirmViewModel: OrderConfirmViewModelType {
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var confirmOrderButtonDidTap = PublishSubject<Void>()
  
  // Output
  var navigationBarTitle: String
  var laundryDescriprionTitle: String
  var laundryIcon: UIImage? = nil
  var laundryRating: Float
  var courierDate: String
  var deliveryDate: String
  var sections: Driver<[OrderConfirmSectionModel]>
  var presentRegistrationSection: Driver<Void>

  
  init(laundry: Laundry) {
    self.navigationBarTitle = laundry.name
    self.laundryDescriprionTitle = laundry.description
    self.laundryRating = laundry.rating
    self.courierDate = laundry.courierDate
    self.deliveryDate = laundry.deliveryDate
    
    self.sections = OrderManager.instance.currentOrderItems
      .asDriver(onErrorDriveWith: .empty())
      .map { orderItems in
        let cellModels = orderItems.map(OrderConfirmServiceTableViewCellModel.init) as [OrderConfirmServiceTableViewCellModelType]
        let section = OrderConfirmSectionModel(model: "", items: cellModels)
        return [section]
      }
    
    self.presentRegistrationSection = confirmOrderButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
  }
}
