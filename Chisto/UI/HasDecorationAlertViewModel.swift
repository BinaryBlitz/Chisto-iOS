//
//  HasDecorationAlertViewModel.swift
//  Chisto
//
//  Created by Алексей on 05.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HasDecorationAlertViewModel {
  let disposeBag = DisposeBag()
  let noButtonDidTap = PublishSubject<Void>()
  let yesButtonDidTap = PublishSubject<Void>()
  let didFinishAlert = PublishSubject<OrderItem>()
  let dismissViewController: Driver<Void>

  let orderItem: OrderItem
  
  init(orderItem: OrderItem) {
    self.orderItem = orderItem
    
    let yesButtonDidTapDriver = yesButtonDidTap.asObservable().do(onNext: {
      orderItem.hasDecoration = true
    }).asDriver(onErrorDriveWith: .empty())

    let noButtonDidTapDriver = noButtonDidTap.asObservable().do(onNext: {
      orderItem.hasDecoration = false
    }).asDriver(onErrorDriveWith: .empty())

    self.dismissViewController = Driver.of(yesButtonDidTapDriver, noButtonDidTapDriver).merge()
  }
}
