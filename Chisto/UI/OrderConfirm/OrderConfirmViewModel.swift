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
  var headerViewDidTap: PublishSubject<Void> { get }
  var confirmOrderButtonDidTap: PublishSubject<Void> { get }

  // Output
  var navigationBarTitle: String { get }
  var laundryDescriprionTitle: String { get }
  var laundryRating: Float { get }
  var orderPrice: String { get }
  var courierDate: String { get }
  var courierPrice: String { get }
  var deliveryDate: String { get }
  var laundryIcon: URL? { get }
  var laundryBackground: URL? { get }
  var sections: Driver<[OrderConfirmSectionModel]> { get }
  var presentRegistrationSection: Driver<Void> { get }
  var presentOrderContactDataSection: Driver<Void> { get }
  var presentLaundryReviewsSection: Driver<LaundryReviewsViewModel> { get }
}

class OrderConfirmViewModel: OrderConfirmViewModelType {

  let disposeBag = DisposeBag()

  // Input
  let headerViewDidTap = PublishSubject<Void>()
  let itemDidSelect = PublishSubject<IndexPath>()
  let confirmOrderButtonDidTap = PublishSubject<Void>()

  // Output
  var navigationBarTitle: String
  var laundryDescriprionTitle: String
  var laundryIcon: URL?  = nil
  var laundryBackground: URL? = nil
  var laundryRating: Float
  var ratingsCountText: String
  var courierDate: String
  var courierPrice: String
  var orderPrice: String
  var deliveryDate: String
  var sections: Driver<[OrderConfirmSectionModel]>
  var presentRegistrationSection: Driver<Void>
  var presentOrderContactDataSection: Driver<Void>
  let presentLaundryReviewsSection: Driver<LaundryReviewsViewModel>
  
  let ratingCountLabels = ["отзыв", "отзыва", "отзывов"]
  
  init(laundry: Laundry) {
    self.navigationBarTitle = laundry.name
    self.laundryDescriprionTitle = laundry.descriptionText
    self.laundryRating = laundry.rating
    self.ratingsCountText = "\(laundry.ratingsCount) " + getRussianNumEnding(number: laundry.ratingsCount, endings: ratingCountLabels)
    self.laundryIcon = URL(string: laundry.logoUrl)
    self.laundryBackground = URL(string: laundry.backgroundImageUrl)
    self.courierDate = laundry.collectionDate.shortDate
    self.courierPrice = laundry.courierPriceString
    self.deliveryDate = laundry.deliveryDate.shortDate
    self.orderPrice = OrderManager.instance.priceString(laundry: laundry)

    self.sections = OrderManager.instance.currentOrderItems
      .asDriver(onErrorDriveWith: .empty())
      .map { orderItems in
        let cellModels = orderItems.map { OrderConfirmServiceTableViewCellModel(orderItem: $0, laundry: laundry) } as [OrderConfirmServiceTableViewCellModelType]
        let section = OrderConfirmSectionModel(model: "", items: cellModels)
        return [section]
      }
    
    let tokenObservable = ProfileManager.instance.userProfile
      .asObservable()
      .map { $0.apiToken }
      .distinctUntilChanged { $0 == $1 }
    let confirmButtonObservable = confirmOrderButtonDidTap.asObservable()
    
    let registrationRequired = Observable.combineLatest(confirmButtonObservable,
      tokenObservable) { _, token -> Bool in token == nil }
    
    self.presentOrderContactDataSection = registrationRequired.filter { $0 == false }.map { _ in }
      .asDriver(onErrorDriveWith: .empty())
    
    self.presentRegistrationSection = registrationRequired.filter { $0 == true }.map { _ in }
      .asDriver(onErrorDriveWith: .empty())
    
    self.presentLaundryReviewsSection = headerViewDidTap
      .map { LaundryReviewsViewModel(laundry: laundry) }
      .asDriver(onErrorDriveWith: .empty())

    confirmOrderButtonDidTap.asDriver(onErrorDriveWith: .empty()).drive(onNext: {
      OrderManager.instance.currentLaundry = laundry
    }).addDisposableTo(disposeBag)
  }

}
