//
//  LastTimePopupViewModel.swift
//  Chisto
//
//  Created by Алексей on 25.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol LastTimePopupViewModelType {
  // Input
  var showAllLaundriesButtonDidTap: PublishSubject<Void> { get }
  var title: String { get }
  var laundryLogoUrl: URL? { get }
  var laundryBackgroundUrl: URL? { get }
  var laundryDescription: String { get }
  // Output
  var laundryDescriptionViewModels: [LaundryItemInfoViewModel] { get }
  var dismissViewController: Driver<Void> { get }
}

class LastTimePopupViewModel: LastTimePopupViewModelType {

  let disposeBag = DisposeBag()

  // Input
  var title: String
  var laundryDescription: String
  var laundryLogoUrl: URL?
  var laundryBackgroundUrl: URL?
  var showAllLaundriesButtonDidTap = PublishSubject<Void>()
  var didChooseLaundry: Observable<Laundry>
  var orderButtonDidTap = PublishSubject<Void>()

  // Output
  let laundryDescriptionViewModels: [LaundryItemInfoViewModel]
  var dismissViewController: Driver<Void>

  init(laundry: Laundry) {
    self.title = String(format: NSLocalizedString("lastTimeOrder", comment: "Last time alert title"), laundry.name)
    self.laundryDescription = laundry.descriptionText
    self.laundryLogoUrl = URL(string: laundry.logoUrl)
    self.laundryBackgroundUrl = URL(string: laundry.backgroundImageUrl)

    let collectionDateString = laundry.collectionFrom.shortDate
    let collectionPrice = OrderManager.instance.collectionPrice(laundry: laundry)
    let collectionPriceString = collectionPrice > 0 ? collectionPrice.currencyString : NSLocalizedString("free", comment: "Price")
    let collectionItemViewModel = LaundryItemInfoViewModel(type: .collection, titleText: collectionDateString, subTitleText: collectionPriceString)

    let deliveryDateString = laundry.deliveryFrom.shortDate
    let deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: deliveryDateString, subTitleText: laundry.deliveryTimeInterval)

    let price = OrderManager.instance.price(laundry: laundry, includeCollection: true)
    let priceString = price.currencyString
    let priceItemViewModel = LaundryItemInfoViewModel(type: .price, titleText: priceString)

    self.laundryDescriptionViewModels = [collectionItemViewModel, deliveryItemViewModel, priceItemViewModel]

    let didChooseLaundry = orderButtonDidTap.map { laundry }
    self.didChooseLaundry = didChooseLaundry

    self.dismissViewController = Observable.of(showAllLaundriesButtonDidTap.asObservable(), didChooseLaundry.map { _ in }).merge()
      .asDriver(onErrorDriveWith: .empty())
  }

}
