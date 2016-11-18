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
  var orderPrice: String { get }
  var courierDate: String { get }
  var deliveryDate: String { get }
  var laundryIcon: URL? { get }
  var laundryBackground: URL? { get }
  var sections: Driver<[OrderConfirmSectionModel]> { get }
  var presentRegistrationSection: Driver<Void> { get }
  var presentOrderContactDataSection: Driver<Void> { get }
}

class OrderConfirmViewModel: OrderConfirmViewModelType {

  let disposeBag = DisposeBag()

  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var confirmOrderButtonDidTap = PublishSubject<Void>()

  // Output
  var navigationBarTitle: String
  var laundryDescriprionTitle: String
  var laundryIcon: URL?  = nil
  var laundryBackground: URL? = nil
  var laundryRating: Float
  var courierDate: String
  var orderPrice: String
  var deliveryDate: String
  var sections: Driver<[OrderConfirmSectionModel]>
  var presentRegistrationSection: Driver<Void>
  var presentOrderContactDataSection: Driver<Void>

  init(laundry: Laundry) {
    self.navigationBarTitle = laundry.name
    self.laundryDescriprionTitle = laundry.descriptionText
    self.laundryRating = laundry.rating
    self.laundryIcon = URL(string: laundry.logoUrl)
    self.laundryBackground = URL(string: laundry.backgroundImageUrl)
    self.courierDate = Date(timeIntervalSince1970: laundry.courierDate).shortDate
    self.deliveryDate = Date(timeIntervalSince1970: laundry.deliveryDate).shortDate
    self.orderPrice = OrderManager.instance.priceString(laundry: laundry)

    self.sections = OrderManager.instance.currentOrderItems
      .asDriver(onErrorDriveWith: .empty())
      .map { orderItems in
        let cellModels = orderItems.map { OrderConfirmServiceTableViewCellModel(orderItem: $0, laundry: laundry) } as [OrderConfirmServiceTableViewCellModelType]
        let section = OrderConfirmSectionModel(model: "", items: cellModels)
        return [section]
      }
    
    let tokenObservable = ProfileManager.instance.apiToken.asObservable().distinctUntilChanged { $0 == $1 }
    let confirmButtonObservable = confirmOrderButtonDidTap.asObservable()
    
    let registrationRequired = Observable.combineLatest(confirmButtonObservable,
      tokenObservable) { _, token -> Bool in token == nil }
    
    self.presentOrderContactDataSection = registrationRequired.filter { $0 == false }.map { _ in }
      .asDriver(onErrorDriveWith: .empty())

    confirmOrderButtonDidTap.asDriver(onErrorDriveWith: .empty()).drive(onNext: {
      OrderManager.instance.currentLaundry = laundry
    }).addDisposableTo(disposeBag)
  }

}
