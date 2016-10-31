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
  // Output
  var laundryDescriptionViewModels: [LaundryItemInfoViewModel] { get }
  var dismissViewController: Driver<Void> { get }
}

class LastTimePopupViewModel: LastTimePopupViewModelType {
  let disposeBag = DisposeBag()
  // Input
  var showAllLaundriesButtonDidTap = PublishSubject<Void>()
  
  // Output
  let laundryDescriptionViewModels: [LaundryItemInfoViewModel]
  var dismissViewController: Driver<Void>
  
  init() {
    let courierItemViewModel = LaundryItemInfoViewModel(type: .courier, titleText: "15.09.2016", subTitleText: "Бесплатно")
    let deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: "11.09.2016", subTitleText: "с 11:00 до 20:00")
    let costItemViewModel = LaundryItemInfoViewModel(type: .cost, titleText: "3 400 ₽")
    
    self.laundryDescriptionViewModels = [courierItemViewModel, deliveryItemViewModel, costItemViewModel]
    
    self.dismissViewController = showAllLaundriesButtonDidTap.asDriver(onErrorDriveWith: .empty())
  }
}
