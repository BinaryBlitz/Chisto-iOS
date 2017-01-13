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

  let disposeBag: DisposeBag
  let formViewModel: ContactFormViewModel

  let buttonsAreEnabled = Variable(false)
  let orderCost: String
  let returnToOrderViewController: PublishSubject<Void>
  let presentLocationSelectSection: Driver<LocationSelectViewModel>
  let payInCashButtonDidTap = PublishSubject<Void>()
  let payWithCreditCardButtonDidTap = PublishSubject<Void>()
  let presentOrderPlacedPopup: Driver<OrderPlacedPopupViewModel>
  let presentPaymentSection: Driver<PaymentViewModel>
  let paymentCompleted: PublishSubject<Order>
  let presentErrorAlert: PublishSubject<Error>
  
  enum NextScreen {
    case orderPlacedPopup(viewModel: OrderPlacedPopupViewModel)
    case payment(viewModel: PaymentViewModel)
  }

  init() {
    let disposeBag =  DisposeBag()
    self.disposeBag = disposeBag
    
    let returnToOrderViewController = PublishSubject<Void>()
    self.returnToOrderViewController = returnToOrderViewController

    let formViewModel = ContactFormViewModel()
    self.formViewModel = formViewModel

    self.orderCost = OrderManager.instance.priceForCurrentLaundry(includeCollection: true).currencyString

    self.presentLocationSelectSection = formViewModel.streetNameFieldDidTap.map {
      let viewModel = LocationSelectViewModel()
      viewModel.streetName.bindTo(formViewModel.street).addDisposableTo(viewModel.disposeBag)
      viewModel.streetNumber.bindTo(formViewModel.building).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())
    
    let paymentCompleted = PublishSubject<Order>()
    self.paymentCompleted = paymentCompleted
    
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert
    
    let placeOrderDriver = formViewModel.saveUserProfile().flatMap {
      return OrderManager.instance.createOrder()
    }.do(onError: { error in
        presentErrorAlert.onNext(error)
    }).asDriver(onErrorDriveWith: .empty())
    
    let payInCashDriver = payInCashButtonDidTap
      .asDriver(onErrorDriveWith: .empty()).flatMap {
        return placeOrderDriver
      }
  
    self.presentPaymentSection = payWithCreditCardButtonDidTap
      .asDriver(onErrorDriveWith: .empty()).flatMap {
        return placeOrderDriver.map { order in
          let viewModel = PaymentViewModel(order: order)
          viewModel.didFinishPayment.bindTo(paymentCompleted).addDisposableTo(disposeBag)
          return viewModel
      }
    }
    
    self.presentOrderPlacedPopup = Driver.of(paymentCompleted.asDriver(onErrorDriveWith: .empty()), payInCashDriver)
      .merge().map { order in
        OrderManager.instance.clearOrderItems()
        return OrderPlacedPopupViewModel(orderNumber: "\(order.id)")
    }
    
    formViewModel.isValid.asObservable().bindTo(buttonsAreEnabled).addDisposableTo(disposeBag)
  }

}
