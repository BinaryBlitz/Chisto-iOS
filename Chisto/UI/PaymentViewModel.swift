//
//  PaymentViewModel.swift
//  Chisto
//
//  Created by Алексей on 25.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PaymentViewModel {
  let disposeBag = DisposeBag()
  let didPressCloseButton = PublishSubject<Void>()
  let didFinishPayment = PublishSubject<Order>()
  let didRedirectToUrl = PublishSubject<URL?>()
  let dismissViewController: Driver<Void>
  var url: URL? = nil
  let successString = "Success=true"
  let order: Order

  init(order: Order) {
    self.order = order
    self.dismissViewController = didPressCloseButton.asDriver(onErrorDriveWith: .empty())
    let payment = order.payment
    self.url = URL(string: payment?.paymentUrl ?? "")
  }
}
