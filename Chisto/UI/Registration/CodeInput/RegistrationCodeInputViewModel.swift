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
  let codeIsValid: Variable<Bool>
  let code: Variable<String?>
  let navigationBarTitle = "Регистрация"
  let dismissViewController: Driver<Void>

  init(phoneNumberString: String) {
    let code = Variable<String?>(nil)
    self.code = code

    let codeIsValid = Variable(true)
    self.codeIsValid = codeIsValid

    self.subTitleText = "На номер +7 \(phoneNumberString) был отправлен код"
    self.resendLabelText = NSAttributedString(string: "Выслать повторно", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])

    let validationConfirmed: Driver<Bool> = code.asDriver()
      .filter { _ in codeIsValid.value == true }
      .flatMap {_ -> Driver<Bool> in
      guard let code = code.value else { return Driver.just(false) }
      return DataManager.instance.verifyToken(code: code.onlyDigits).map { true }.asDriver(onErrorDriveWith: Driver.just(false))
    }

    self.dismissViewController = validationConfirmed.filter { $0 == true }.map { _ in }
  }

}
