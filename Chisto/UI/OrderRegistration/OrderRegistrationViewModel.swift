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
import PassKit

class OrderRegistrationViewModel {

  let disposeBag: DisposeBag
  let formViewModel: ContactFormViewModel

  let buttonsAreEnabled = Variable(false)
  let orderPrice: String
  let returnToOrderViewController: PublishSubject<Void>
  let presentLocationSelectSection: Driver<LocationSelectViewModel>
  let payButtonDidTap = PublishSubject<Void>()
  let presentOrderPlacedPopup: Driver<OrderPlacedPopupViewModel>
  let presentPaymentSection: Driver<PaymentViewModel>
  let currentOrder: Variable<Order?>
  let paymentCompleted: PublishSubject<Order>
  let presentErrorAlert: PublishSubject<Error>
  let applePayDidFinish: PublishSubject<Void>
  let presentApplePayScreen: Driver<PKPaymentRequest>
  let canUseApplePay = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.masterCard, .visa])

  enum NextScreen {
    case orderPlacedPopup(viewModel: OrderPlacedPopupViewModel)
    case payment(viewModel: PaymentViewModel)
  }

  init(promoCode: PromoCode? = nil) {
    let disposeBag = DisposeBag()
    self.disposeBag = disposeBag

    let returnToOrderViewController = PublishSubject<Void>()
    self.returnToOrderViewController = returnToOrderViewController

    let formViewModel = ContactFormViewModel(currentScreen: .orderRegistration)
    self.formViewModel = formViewModel

    let currentOrder = Variable<Order?>(nil)
    self.currentOrder = currentOrder

    let orderPrice = OrderManager.instance.priceForCurrentLaundry(includeCollection: true, promoCode: promoCode)
    self.orderPrice = orderPrice.currencyString

    self.presentLocationSelectSection = formViewModel.streetNameFieldDidTap.map {
      let viewModel = LocationSelectViewModel()

      viewModel.streetName.bind(to: formViewModel.street).addDisposableTo(viewModel.disposeBag)
      viewModel.streetNumber.bind(to: formViewModel.building).addDisposableTo(viewModel.disposeBag)

      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    let applePayDidFinish = PublishSubject<Void>()
    self.applePayDidFinish = applePayDidFinish

    let paymentCompleted = PublishSubject<Order>()
    self.paymentCompleted = paymentCompleted

    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    let placeOrder: () -> Driver<Order>
    placeOrder = { method in
      let placeOrderDriver = formViewModel.saveUserProfile().flatMap {
          return OrderManager.instance.createOrder(promoCode: promoCode)
        }.do(onError: { error in
          presentErrorAlert.onNext(error)
        }).asDriver(onErrorDriveWith: .empty())

      placeOrderDriver.asObservable().bind(to: currentOrder).addDisposableTo(disposeBag)
      return placeOrderDriver
    }

    let payInCashDriver = payButtonDidTap.filter { formViewModel.paymentMethod.value == .cash }
      .asDriver(onErrorDriveWith: .empty()).flatMap {
        return placeOrder()
      }

    self.presentApplePayScreen = payButtonDidTap.filter { formViewModel.paymentMethod.value == .applePay }
      .asDriver(onErrorDriveWith: .empty()).flatMap {
        return placeOrder().map { $0.paymentRequest }
    }

    applePayDidFinish
      .asObservable()
      .filter { currentOrder.value != nil }
      .map { currentOrder.value! }
      .filter { $0.paid }
      .bind(to: paymentCompleted)
      .addDisposableTo(disposeBag)

    self.presentPaymentSection = payButtonDidTap
      .filter { formViewModel.paymentMethod.value == .card }
      .asDriver(onErrorDriveWith: .empty()).flatMap {
        return placeOrder().map { order in
          let viewModel = PaymentViewModel(order: order)

          viewModel.didFinishPayment
            .bind(to: paymentCompleted)
            .addDisposableTo(disposeBag)

          return viewModel
        }
      }

    self.presentOrderPlacedPopup = Driver.of(paymentCompleted.asDriver(onErrorDriveWith: .empty()), payInCashDriver)
      .merge().map { order in
        order.logPurchase()
        OrderManager.instance.clearOrderItems()
        return OrderPlacedPopupViewModel(orderNumber: "\(order.id)")
      }

    formViewModel.isValid.asObservable().bind(to: buttonsAreEnabled).addDisposableTo(disposeBag)

    formViewModel.presentErrorAlert
      .bind(to: presentErrorAlert)
      .addDisposableTo(disposeBag)
  }

  func sendPaymentToken(token: Data, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
    guard let order = currentOrder.value else { return completion(.failure) }
    DataManager.instance.sendOrderPaymentToken(orderId: order.id, paymentData: token).subscribe(onNext: { order in
      self.currentOrder.value = order
      completion(.success)
    }, onError: { _ in
      completion(.failure)
    }).addDisposableTo(disposeBag)

  }

}
