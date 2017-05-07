//
//  PromoCodeAlertViewModel.swift
//  Chisto
//
//  Created by Алексей on 21.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PromoCodeAlertViewModel {
  let disposeBag = DisposeBag()
  let promoCodeDidEntered: Driver<PromoCode?>
  let continueButtonDidTap = PublishSubject<Void>()
  let didFinishEnteringCode = PublishSubject<Void>()
  let didPickEmptyPromoCode: Driver<Void>
  let dismissViewController: Driver<Void>
  let promoCodeText: Variable<String?>

  init() {
    let promoCodeText = Variable<String?>("")
    self.promoCodeText = promoCodeText
    let didPickPromoCode = didFinishEnteringCode
      .asDriver(onErrorDriveWith: .empty())
      .map { promoCodeText.value ?? "" }

    self.didPickEmptyPromoCode = didPickPromoCode
      .filter { $0.isEmpty }
      .map { _ in () }

    self.promoCodeDidEntered = didPickPromoCode
      .filter { !$0.isEmpty }
      .flatMap { code in
        DataManager.instance.showPromoCode(code: code).asDriver(onErrorDriveWith: .just(nil))
      }
    self.dismissViewController = continueButtonDidTap.asDriver(onErrorDriveWith: .empty())
  }

}
