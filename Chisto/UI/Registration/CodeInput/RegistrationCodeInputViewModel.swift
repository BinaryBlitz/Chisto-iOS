//
//  RegistrationCodeInputViewModel.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RegistrationCodeInputViewModel {

  let subTitleText: String
  let resendLabelText: NSAttributedString
  let licenseAgreementText: NSAttributedString
  let codeIsValid: Variable<Bool>
  let code: Variable<String?>
  let navigationBarTitle = "Регистрация"
  let dismissViewController: Driver<Void>
  let didFinishRegistration = PublishSubject<Void>()

  let termsOfServiceURL = DataManager.instance.termsOfServiceURL

  init(phoneNumberString: String) {
    let code = Variable<String?>(nil)
    self.code = code

    let codeIsValid = Variable(true)
    self.codeIsValid = codeIsValid

    self.subTitleText = "На номер \(phoneNumberString) был отправлен код"
    self.resendLabelText = NSAttributedString(string: "Выслать повторно", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])

    let licenseAgreementString = NSMutableAttributedString()
    licenseAgreementString.append(NSAttributedString(string: "Регистрируясь в приложении, вы принимаете условия "))
    licenseAgreementString.append(NSAttributedString(string: "Пользовательского соглашения", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]))
    self.licenseAgreementText = licenseAgreementString

    let validationConfirmed: Driver<Bool> = code.asDriver()
      .filter { _ in codeIsValid.value == true }
      .flatMap {_ -> Driver<Bool> in
      guard let code = code.value else { return Driver.just(false) }
      return DataManager.instance.verifyToken(code: code.onlyDigits).map { true }.asDriver(onErrorDriveWith: Driver.just(false))
    }

    self.dismissViewController = validationConfirmed.filter { $0 == true }.flatMap { _ -> Driver<Void> in
      return DataManager.instance.showUser().asDriver(onErrorDriveWith: .empty())
    }.map { _ in }
  }

}
