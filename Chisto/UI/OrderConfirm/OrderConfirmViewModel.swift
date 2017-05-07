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
  var sections: Driver<[OrderConfirmSectionModel]> { get }
  var presentOrderContactDataSection: Driver<OrderRegistrationViewModel> { get }
  var presentLaundryReviewsSection: Driver<LaundryReviewsViewModel> { get }

  var laundryDescriprionTitle: String { get }
  var laundryIcon: URL? { get }
  var laundryBackground: URL? { get }
  var laundryRating: Float { get }
  var ratingsCountText: String { get }
  var collectionDate: String { get }
  var collectionTime: String { get }
  var deliveryDate: String { get }
  var deliveryTime: String { get }
}

class OrderConfirmViewModel: OrderConfirmViewModelType {

  let disposeBag = DisposeBag()

  // Input
  let itemDidSelect = PublishSubject<IndexPath>()
  let confirmOrderButtonDidTap = PublishSubject<Void>()

  // Output
  var navigationBarTitle: String
  var sections: Driver<[OrderConfirmSectionModel]>
  var presentOrderContactDataSection: Driver<OrderRegistrationViewModel>
  let presentLaundryReviewsSection: Driver<LaundryReviewsViewModel>
  let confirmOrderButtonTitle: Observable<String>
  let presentPromoCodeAlert: Driver<PromoCodeAlertViewModel>
  let orderConfirmTableHeaderViewModel: OrderConfirmTableHeaderViewModel
  let headerViewDidTap = PublishSubject<Void>()
  let presentErrorAlert: PublishSubject<String>

  var laundryDescriprionTitle: String
  var laundryIcon: URL? = nil
  var laundryBackground: URL? = nil
  var laundryRating: Float
  var ratingsCountText: String
  var collectionDate: String
  var collectionTime: String
  var deliveryDate: String
  let deliveryTime: String

  let ratingCountLabels = [NSLocalizedString("ratingNominitive", comment: "Ratings count"), NSLocalizedString("ratingGenitive", comment: "Ratings count"), NSLocalizedString("ratingsGenitive", comment: "Ratings count")]
  let promoCode: Variable<PromoCode?>

  enum NextScreen {
    case phoneRegistration(viewModel: RegistrationPhoneInputViewModel)
    case orderRegistration
  }

  init(laundry: Laundry) {
    let presentErrorAlert = PublishSubject<String>()
    self.presentErrorAlert = presentErrorAlert

    self.navigationBarTitle = laundry.name
    let promoCode = Variable<PromoCode?>(nil)
    self.promoCode = promoCode
    self.confirmOrderButtonTitle = promoCode.asObservable().map { promoCode in
      let price = OrderManager.instance.price(laundry: laundry, includeCollection: true, promoCode: promoCode)
      return NSLocalizedString("confirmOrder", comment: "Order confirm button") + price.currencyString
    }
    self.laundryDescriprionTitle = laundry.descriptionText
    self.laundryRating = laundry.rating
    self.ratingsCountText = "\(laundry.ratingsCount) " + getRussianNumEnding(number: laundry.ratingsCount, endings: ratingCountLabels)
    self.laundryIcon = URL(string: laundry.logoUrl)
    self.laundryBackground = URL(string: laundry.backgroundImageUrl)
    self.collectionDate = laundry.collectionFrom.shortDate
    self.deliveryDate = laundry.deliveryFrom.shortDate
    self.deliveryTime = laundry.deliveryTimeInterval
    self.collectionTime = laundry.collectionTimeInterval

    let orderConfirmTableHeaderViewModel = OrderConfirmTableHeaderViewModel(laundry: laundry)
    self.orderConfirmTableHeaderViewModel = orderConfirmTableHeaderViewModel
    promoCode.asObservable().bind(to: orderConfirmTableHeaderViewModel.promoCode).addDisposableTo(disposeBag)

    self.presentPromoCodeAlert = orderConfirmTableHeaderViewModel.promoCodeButtonDidTap.map {
      let viewModel = PromoCodeAlertViewModel()
      viewModel.promoCodeDidEntered.asObservable()
        .filter { $0 != nil }
        .map { $0! }
        .bind(to: promoCode).addDisposableTo(viewModel.disposeBag)

      viewModel.didPickEmptyPromoCode.asObservable()
        .map { _ in NSLocalizedString("promoCodeIsEmpty", comment: "Error alert") }
        .bind(to: presentErrorAlert)
        .addDisposableTo(viewModel.disposeBag)

      viewModel.promoCodeDidEntered.asObservable()
        .filter { $0 == nil }
        .map { _ in NSLocalizedString("promocodeNotFound", comment: "Error alert") }
        .bind(to: presentErrorAlert)
        .addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    self.sections = OrderManager.instance.currentOrderItems
      .asDriver(onErrorDriveWith: .empty())
      .map { orderItems in
        let cellModels = orderItems.map { OrderConfirmServiceTableViewCellModel(orderItem: $0, laundry: laundry) } as [OrderConfirmServiceTableViewCellModelType]
        let section = OrderConfirmSectionModel(model: "", items: cellModels)
        return [section]
      }

    let didFinishRegistation = PublishSubject<Void>()

    let shouldPresentOrderContactDataSection = confirmOrderButtonDidTap.asObservable().filter { ProfileManager.instance.userProfile.value.isVerified }.flatMap {
      return DataManager.instance.showUser().asDriver(onErrorDriveWith: .just())
    }

    let shouldPresentRegistrationSection = confirmOrderButtonDidTap.asObservable().filter { !ProfileManager.instance.userProfile.value.isVerified }

    self.presentOrderContactDataSection = confirmOrderButtonDidTap
      .asDriver(onErrorDriveWith: .empty())
      .map { OrderRegistrationViewModel(promoCode: promoCode.value) }

    self.presentLaundryReviewsSection = headerViewDidTap
      .map { LaundryReviewsViewModel(laundry: laundry) }
      .asDriver(onErrorDriveWith: .empty())

    confirmOrderButtonDidTap.asDriver(onErrorDriveWith: .empty()).drive(onNext: {
        OrderManager.instance.currentLaundry = laundry
      }).addDisposableTo(disposeBag)
  }

}
