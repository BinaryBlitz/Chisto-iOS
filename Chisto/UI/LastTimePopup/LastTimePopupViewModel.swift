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

  // Output
  let laundryDescriptionViewModels: [LaundryItemInfoViewModel]
  var dismissViewController: Driver<Void>

  init(laundry: Laundry) {
    self.title = "В прошлый раз вы заказывали в химчистке \(laundry.name)"
    self.laundryDescription = laundry.descriptionText
    self.laundryLogoUrl = URL(string: laundry.logoUrl)
    self.laundryBackgroundUrl = URL(string: laundry.backgroundImageUrl)

    let courierDateString = laundry.collectionDate.shortDate
    let courierItemViewModel = LaundryItemInfoViewModel(type: .courier, titleText: courierDateString, subTitleText: laundry.courierPriceString)

    let deliveryDateString = laundry.deliveryDate.shortDate
    let deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: deliveryDateString, subTitleText: laundry.deliveryTimeInterval)

    let costString = OrderManager.instance.priceString(laundry: laundry)
    let costItemViewModel = LaundryItemInfoViewModel(type: .cost, titleText: costString)

    self.laundryDescriptionViewModels = [courierItemViewModel, deliveryItemViewModel, costItemViewModel]

    self.dismissViewController = showAllLaundriesButtonDidTap.asDriver(onErrorDriveWith: .empty())
  }

}
