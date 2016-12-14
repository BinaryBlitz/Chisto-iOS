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

  let orderItem: OrderItem

  let decorationAlertTitle = "Есть ли у вещи декоративная отделка?"
  let decorationAlertMessage = "К декоративной отделке относятся стразы, бисер, пайетки, сложные кружевные композиции и прочие украшения одежды, нуждающиеся в особом уходе и внимании со стороны химчистки."

  init(orderItem: OrderItem) {
    self.orderItem = orderItem
    
    let yesButtonDidTapObservable = yesButtonDidTap.asObservable().do(onNext: {
      orderItem.hasDecoration = true
    })

    let noButtonDidTapObservable = noButtonDidTap.asObservable().do(onNext: {
      orderItem.hasDecoration = false
    })

    Observable.of(yesButtonDidTapObservable, noButtonDidTapObservable).merge().map { orderItem }
      .bindTo(didFinishAlert)
      .addDisposableTo(disposeBag)
  }
}
