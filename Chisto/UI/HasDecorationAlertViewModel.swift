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
  let disableAlertButtonDidTap = PublishSubject<Void>()
  let didFinishAlert = PublishSubject<OrderItem>()

  let orderItem: OrderItem

  let decorationAlertTitle = NSLocalizedString("hasDecorationRequest", comment: "Decoration alert")
  let decorationAlertMessage = NSLocalizedString("decorationDescription", comment: "Decoration alert")

  init(orderItem: OrderItem) {
    self.orderItem = orderItem

    let yesButtonDidTapObservable = yesButtonDidTap.asObservable().do(onNext: {
      orderItem.hasDecoration = true
    })

    let noButtonDidTapObservable = noButtonDidTap.asObservable().do(onNext: {
      orderItem.hasDecoration = false
    })

    let disableAlertButtonDidTapObservable = disableAlertButtonDidTap.asObservable().do(onNext: {
      ProfileManager.instance.updateProfile { profile in
        profile.disabledDecorationAlert = true
      }
    })

    Observable.of(yesButtonDidTapObservable, noButtonDidTapObservable, disableAlertButtonDidTapObservable).merge().map { orderItem }
      .bindTo(didFinishAlert)
      .addDisposableTo(disposeBag)
  }
}
