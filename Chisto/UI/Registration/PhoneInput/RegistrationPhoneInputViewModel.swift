//
//  RegistrationPhoneInputViewModel.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PhoneNumberKit

class RegistrationPhoneInputViewModel {
  let disposeBag: DisposeBag
  let presentCodeInputSection: Observable<RegistrationCodeInputViewModel>
  let didFinishRegistration: PublishSubject<Void>
  let sendButtonDidTap = PublishSubject<Void>()
  let phoneText: Variable<String?>
  let navigationBarTitle = "Регистрация"

  init() {
    let disposeBag = DisposeBag()
    self.disposeBag = disposeBag
    
    let phoneText = Variable<String?>(nil)
    self.phoneText = phoneText
    
    let didFinishRegistration = PublishSubject<Void>()
    self.didFinishRegistration = didFinishRegistration

    self.presentCodeInputSection = sendButtonDidTap.asObservable().flatMap { _ -> Observable<RegistrationCodeInputViewModel> in
      guard let phoneText = phoneText.value else { return Observable.error(DataError.unknown) }
      let phoneNumberKit = PhoneNumberKit()
      guard let phoneNumber = try? phoneNumberKit.parse(phoneText) else { return Observable.error(DataError.unknown) }
      return DataManager.instance.createVerificationToken(phone: phoneNumberKit.format(phoneNumber, toType: .e164)).map {
        let viewModel = RegistrationCodeInputViewModel(phoneNumberString: phoneText)
        viewModel.didFinishRegistration.bindTo(didFinishRegistration).addDisposableTo(disposeBag)
        return viewModel
      }
    }
  }

}
