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
  var collectionDate: String { get }
  var collectionPrice: String { get }
  var deliveryDate: String { get }
  var laundryIcon: URL? { get }
  var laundryBackground: URL? { get }
  var sections: Driver<[OrderConfirmSectionModel]> { get }
  var presentRegistrationSection: Driver<RegistrationPhoneInputViewModel> { get }
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
  var collectionDate: String
  var collectionPrice: String
  var orderPrice: String
  var deliveryDate: String
  var sections: Driver<[OrderConfirmSectionModel]>
  var presentRegistrationSection: Driver<RegistrationPhoneInputViewModel>
  var presentOrderContactDataSection: Driver<Void>
  let presentLaundryReviewsSection: Driver<LaundryReviewsViewModel>
  let confirmOrderButtonTitle: String
  let hoursTitle: String

  let ratingCountLabels = ["отзыв", "отзыва", "отзывов"]
  
  enum NextScreen {
    case phoneRegistration(viewModel: RegistrationPhoneInputViewModel)
    case orderRegistration
  }
  
  init(laundry: Laundry) {
    self.navigationBarTitle = laundry.name
    self.laundryDescriprionTitle = laundry.descriptionText
    self.laundryRating = laundry.rating
    self.ratingsCountText = "\(laundry.ratingsCount) " + getRussianNumEnding(number: laundry.ratingsCount, endings: ratingCountLabels)
    self.laundryIcon = URL(string: laundry.logoUrl)
    self.laundryBackground = URL(string: laundry.backgroundImageUrl)
    self.collectionDate = laundry.collectionDate.shortDate
    let price = OrderManager.instance.price(laundry: laundry)
    let collectionPrice = laundry.collectionPrice(amount: price)
    self.collectionPrice = collectionPrice > 0 ? collectionPrice.currencyString : "Бесплатно"
    self.deliveryDate = laundry.deliveryDate.shortDate
    self.orderPrice = price.currencyString

    let totalPrice = price + collectionPrice
    self.confirmOrderButtonTitle = "Оформить заказ: " + totalPrice.currencyString
    self.hoursTitle = laundry.deliveryTimeInterval

    self.sections = OrderManager.instance.currentOrderItems
      .asDriver(onErrorDriveWith: .empty())
      .map { orderItems in
        let cellModels = orderItems.map { OrderConfirmServiceTableViewCellModel(orderItem: $0, laundry: laundry) } as [OrderConfirmServiceTableViewCellModelType]
        let section = OrderConfirmSectionModel(model: "", items: cellModels)
        return [section]
      }
    
    let didFinishRegistation = PublishSubject<Void>()

    let shouldPresentOrderContactDataSection = confirmOrderButtonDidTap.asObservable().filter { ProfileManager.instance.userProfile.value.isVerified }
    let shouldPresentRegistrationSection = confirmOrderButtonDidTap.asObservable().filter { !ProfileManager.instance.userProfile.value.isVerified }

    self.presentOrderContactDataSection = Driver.of(shouldPresentOrderContactDataSection.asDriver(onErrorDriveWith: .empty()), didFinishRegistation.asDriver(onErrorDriveWith: .empty()))
      .merge().flatMap {
        return DataManager.instance.showUser().asDriver(onErrorDriveWith: .just())
    }
    
    self.presentRegistrationSection = shouldPresentRegistrationSection.map {
      let viewModel = RegistrationPhoneInputViewModel()
      viewModel.didFinishRegistration.bindTo(didFinishRegistation).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())
    
    self.presentLaundryReviewsSection = headerViewDidTap
      .map { LaundryReviewsViewModel(laundry: laundry) }
      .asDriver(onErrorDriveWith: .empty())

    confirmOrderButtonDidTap.asDriver(onErrorDriveWith: .empty()).drive(onNext: {
      OrderManager.instance.currentLaundry = laundry
    }).addDisposableTo(disposeBag)
  }

}
