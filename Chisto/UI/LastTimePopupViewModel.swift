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
    
    let courierItemViewModel = LaundryItemInfoViewModel(type: .courier, titleText: laundry.courierDate, subTitleText: laundry.courierPriceString)
    let deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: laundry.deliveryDate, subTitleText: laundry.deliveryTimeInterval)
    let costItemViewModel = LaundryItemInfoViewModel(type: .cost, titleText: laundry.costString)
    
    self.laundryDescriptionViewModels = [courierItemViewModel, deliveryItemViewModel, costItemViewModel]
    
    self.dismissViewController = showAllLaundriesButtonDidTap.asDriver(onErrorDriveWith: .empty())
  }
}
