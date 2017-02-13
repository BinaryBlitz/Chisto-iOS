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
  let licenseAgreementText: NSAttributedString
  let phoneText: Variable<String?>
  let navigationBarTitle = NSLocalizedString("registrationPhoneInputScreen", comment: "Phone input screen title")

  let termsOfServiceURL = DataManager.instance.termsOfServiceURL

  init() {
    let disposeBag = DisposeBag()
    self.disposeBag = disposeBag
    
    let phoneText = Variable<String?>(nil)
    self.phoneText = phoneText
    
    let didFinishRegistration = PublishSubject<Void>()
    self.didFinishRegistration = didFinishRegistration

    let licenseAgreementString = NSMutableAttributedString()
    licenseAgreementString.append(NSAttributedString(string: NSLocalizedString("licenseAgreementDescription1", comment: "License agreement") + " "))
    licenseAgreementString.append(NSAttributedString(string: NSLocalizedString("licenseAgreementDescription2", comment: "License agreement"), attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]))
    self.licenseAgreementText = licenseAgreementString

    self.presentCodeInputSection = sendButtonDidTap.asObservable().flatMap { _ -> Observable<RegistrationCodeInputViewModel> in
      guard let phoneText = phoneText.value else { return Observable.error(DataError.unknown(description: "")) }
      let phoneNumberKit = PhoneNumberKit()
      guard let phoneNumber = try? phoneNumberKit.parse(phoneText) else { return Observable.error(DataError.unknown(description: NSLocalizedString("invalidPhone", comment: "Error alert"))) }
      return DataManager.instance.createVerificationToken(phone: phoneNumberKit.format(phoneNumber, toType: .e164)).map {
        let viewModel = RegistrationCodeInputViewModel(phoneNumberString: phoneText)
        viewModel.didFinishRegistration.bindTo(didFinishRegistration).addDisposableTo(disposeBag)
        return viewModel
      }
    }
  }

}
