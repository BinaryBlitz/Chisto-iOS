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
  let formViewModel: ContactFormViewModel

  let buttonsAreEnabled = Variable(false)
  let orderCost: String
  let returnToOrderViewController: PublishSubject<Void>
  let presentLocationSelectSection: Driver<LocationSelectViewModel>
  let payInCashButtonDidTap = PublishSubject<Void>()
  let payWithCreditCardButtonDidTap = PublishSubject<Void>()
  let presentOrderPlacedPopup: Observable<OrderPlacedPopupViewModel>

  init() {
    
    let returnToOrderViewController = PublishSubject<Void>()
    self.returnToOrderViewController = returnToOrderViewController

    let formViewModel = ContactFormViewModel()
    self.formViewModel = formViewModel

    self.orderCost = OrderManager.instance.priceForCurrentLaundryString

    self.presentLocationSelectSection = formViewModel.locationHeaderButtonDidTap.map {
      let viewModel = LocationSelectViewModel()
      viewModel.streetName.bindTo(formViewModel.street).addDisposableTo(viewModel.disposeBag)
      viewModel.streetNumber.bindTo(formViewModel.building).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    self.presentOrderPlacedPopup = Observable.of(payWithCreditCardButtonDidTap.asObservable(), payInCashButtonDidTap.asObservable()).merge()
      .flatMap { _ -> Observable<OrderPlacedPopupViewModel> in
        
        formViewModel.saveUserProfile()
        
        return OrderManager.instance.placeOrder().map { order in
          let viewModel = OrderPlacedPopupViewModel(orderNumber: "\(order.id)")
          viewModel.returnToOrderViewController.asObservable()
            .bindTo(returnToOrderViewController)
            .addDisposableTo(viewModel.disposeBag)
          return viewModel
        }
      }

    formViewModel.isValid.asObservable().bindTo(buttonsAreEnabled).addDisposableTo(disposeBag)
  }

}
