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
  var sendButtonEnabled = Variable<Bool>(true)
  let phoneIsValidated = Variable<Bool>(false)
  let phone = Variable<String?>(nil)
  let code = Variable<String?>("")
  var codeIsValid = Variable<Bool>(false)
  let sendButtonDidTap = PublishSubject<Void>()
  let presentErrorAlert = PublishSubject<Error>()

  var timer: Timer!
  var seconds = Variable<Int>(60)

  let secondsCountLabels = [
    NSLocalizedString("secondNominitive", comment: "Send code alert"),
    NSLocalizedString("secondGenitive", comment: "Send code alert"),
    NSLocalizedString("secondsGenitive", comment: "Send code alert")
  ]

  init() {
    ProfileManager.instance
      .userProfile
      .asObservable()
      .map { $0.apiToken != nil }
      .distinctUntilChanged()
      .bind(to: phoneIsValidated)
      .addDisposableTo(disposeBag)

    let sendButtonObservable = sendButtonDidTap.asObservable().map { self.sendButtonEnabled.value }

    sendButtonObservable
      .filter { $0 }
      .flatMap { [weak self] _ -> Observable<Void> in
        self?.configureTimer()
        guard let phoneText = self?.phone.value else { return Observable.error(DataError.unknown(description: "")) }
        let phoneNumberKit = PhoneNumberKit()
        guard let phoneNumber = try? phoneNumberKit.parse(phoneText) else { return Observable.error(DataError.unknown(description: NSLocalizedString("invalidPhone", comment: "Error alert"))) }
        return DataManager.instance.createVerificationToken(phone: phoneNumberKit.format(phoneNumber, toType: .e164))
      }.subscribe(onError: { [weak self] error in
        self?.presentErrorAlert.onNext(error)
      }).addDisposableTo(disposeBag)

    sendButtonObservable
      .skip(1)
      .filter { !$0 }
      .map { [weak self] _ in
        guard let `self` = self else { return DataError.unknown(description: "") }
        let seconds = self.seconds.value
        let message = String(format: NSLocalizedString("codeSentTryAgain", comment: "Registration"), "\(seconds)") + getRussianNumEnding(number: seconds, endings: self.secondsCountLabels)
        return DataError.unknown(description: message)
      }
      .bind(to: presentErrorAlert)
      .addDisposableTo(disposeBag)

    let validationConfirmed: Driver<Bool> = codeIsValid.asDriver()
      .filter { $0 }
      .flatMap { [weak self ] _ -> Driver<Bool> in
        guard let code = self?.code.value else { return Driver.just(false) }
        return DataManager.instance.verifyToken(code: code.onlyDigits).map { true }.asDriver(onErrorDriveWith: Driver.just(false))
  }

    validationConfirmed
      .filter { $0 }
      .flatMap { _ -> Driver<Void> in
      NotificationManager.instance.enable()
      return DataManager.instance.showUser().asDriver(onErrorDriveWith: .empty())
    }.drive().addDisposableTo(disposeBag)
  }

  func configureTimer() {
    sendButtonEnabled.value = false
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ContactFormPhoneViewModel.updateTimer), userInfo: nil, repeats: true)
    timer.fire()
  }

  @objc func updateTimer() {
    seconds.value -= 1
    if seconds.value == 0 {
      timer.invalidate()
      sendButtonEnabled.value = true
      seconds.value = 60
    }
  }
}
