//
//  ContactFormPhoneViewModel.swift
//  Chisto
//
//  Created by Алексей on 30.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PassKit
import UIKit
import PhoneNumberKit

class ContactFormPhoneViewModel {
  let disposeBag = DisposeBag()
  let sendButtonDidTap = PublishSubject<Void>()
  let sendButtonEnabled = Variable<Bool>(true)
  let phoneIsValidated = Variable<Bool>(false)
  let phone = Variable<String?>(nil)
  let code = Variable<String?>("")
  var codeIsValid = Variable<Bool>(false)
  let presentErrorAlert = PublishSubject<Error>()

  init() {
    ProfileManager.instance
      .userProfile
      .asObservable()
      .map { $0.apiToken != nil }
      .bind(to: phoneIsValidated)
      .addDisposableTo(disposeBag)

    sendButtonDidTap.asObservable().flatMap { [weak self] _ -> Observable<Void> in
      self?.sendButtonEnabled.value = false
      guard let phoneText = self?.phone.value else { return Observable.error(DataError.unknown(description: "")) }
      let phoneNumberKit = PhoneNumberKit()
      guard let phoneNumber = try? phoneNumberKit.parse(phoneText) else { return Observable.error(DataError.unknown(description: NSLocalizedString("invalidPhone", comment: "Error alert"))) }
      return DataManager.instance.createVerificationToken(phone: phoneNumberKit.format(phoneNumber, toType: .e164))
      }.subscribe(onNext: { [weak self] _ in
        self?.sendButtonEnabled.value = true
      }, onError: { [weak self] error in
        self?.sendButtonEnabled.value = true
        self?.presentErrorAlert.onNext(error)
      }).addDisposableTo(disposeBag)

    let validationConfirmed: Driver<Bool> = codeIsValid.asDriver()
      .filter { $0 == true }
      .flatMap { [weak self ] _ -> Driver<Bool> in
        guard let code = self?.code.value else { return Driver.just(false) }
        return DataManager.instance.verifyToken(code: code.onlyDigits).map { true }.asDriver(onErrorDriveWith: Driver.just(false))
    }

    validationConfirmed
      .filter { $0 == true }
      .flatMap { _ -> Driver<Void> in
      NotificationManager.instance.enable()
      return DataManager.instance.showUser().asDriver(onErrorDriveWith: .empty())
    }.drive().addDisposableTo(disposeBag)

  }
}
