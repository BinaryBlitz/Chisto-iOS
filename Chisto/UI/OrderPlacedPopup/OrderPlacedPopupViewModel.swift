//
//  OrderConfirmedPopupViewModel.swift
//  Chisto
//
//  Created by Алексей on 13.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrderPlacedPopupViewModel {

  let disposeBag = DisposeBag()

  let continueButtonDidTap = PublishSubject<Void>()
  let dismissViewController: Driver<Void>
  let returnToOrderViewController = PublishSubject<Void>()
  let orderNumber: String

  init(orderNumber: String) {
    self.orderNumber = "№ " + orderNumber
    self.dismissViewController = continueButtonDidTap.asDriver(onErrorDriveWith: .empty())
  }

}
