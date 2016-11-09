//
//  OrderRegistrationViewModel.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OrderRegistrationViewModel {
  let disposeBag = DisposeBag()
  let formViewModel = ContactFormViewModel()
  let buttonsAreEnabled = Variable(false)
  let orderCost: String
  let dismissViewController: Driver<Void>
  let cityDidSelect: PublishSubject<Void>
  let presentCitySelectSection: Driver<CitySelectViewModel>
  
  init() {
    let cityDidSelect = PublishSubject<Void>()
    self.cityDidSelect = cityDidSelect
    self.dismissViewController = cityDidSelect.asDriver(onErrorDriveWith: .empty())
    
    self.orderCost = OrderManager.instance.priceForCurrentLaundryString
    self.presentCitySelectSection = formViewModel.cityFieldDidTap
      .asObservable().map {
        let viewModel = CitySelectViewModel()
        viewModel.itemDidSelect
          .asObservable().map{ _ in Void() }
          .bindTo(cityDidSelect)
          .addDisposableTo(viewModel.disposeBag)
        return viewModel
      }.asDriver(onErrorDriveWith: .empty())

    formViewModel.isValid.asObservable().bindTo(buttonsAreEnabled).addDisposableTo(disposeBag)

  }
}
