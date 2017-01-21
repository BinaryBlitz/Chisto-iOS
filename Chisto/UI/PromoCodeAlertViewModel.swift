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
  let promoCodeDidEntered: Observable<String?>
  let continueButtonDidTap = PublishSubject<Void>()
  let dismissViewController: Driver<Void>
  let promoCodeText: Variable<String?>

  init() {
    let promoCodeText = Variable<String?>("")
    self.promoCodeText = promoCodeText
    self.promoCodeDidEntered = continueButtonDidTap.map { promoCodeText.value }
    self.dismissViewController = continueButtonDidTap.asDriver(onErrorDriveWith: .empty())
  }

}
