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
  let dismissViewController: Driver<Void>
  let didFinishRegistration = PublishSubject<Void>()

  let termsOfServiceURL = DataManager.instance.termsOfServiceURL

  init(phoneNumberString: String) {
    let code = Variable<String?>(nil)
    self.code = code

    let codeIsValid = Variable(true)
    self.codeIsValid = codeIsValid

    self.subTitleText = String(format: NSLocalizedString("codeSent", comment: "Code input screen"), phoneNumberString)
    self.resendLabelText = NSAttributedString(string: NSLocalizedString("sendAgain", comment: "Code input screen"), attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle): NSUnderlineStyle.single.rawValue]))

    let licenseAgreementString = NSMutableAttributedString()
    licenseAgreementString.append(NSAttributedString(string: NSLocalizedString("licenseAgreementDescription1", comment: "License agreement") + " "))
    licenseAgreementString.append(NSAttributedString(string: NSLocalizedString("licenseAgreementDescription2", comment: "License agreement"), attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle): NSUnderlineStyle.single.rawValue])))
    self.licenseAgreementText = licenseAgreementString

    let validationConfirmed: Driver<Bool> = code.asDriver()
      .filter { _ in codeIsValid.value == true }
      .flatMap { _ -> Driver<Bool> in
        guard let code = code.value else { return Driver.just(false) }
        return DataManager.instance.verifyToken(code: code.onlyDigits).map { true }.asDriver(onErrorDriveWith: Driver.just(false))
      }

    self.dismissViewController = validationConfirmed.filter { $0 == true }.flatMap { _ -> Driver<Void> in
      NotificationManager.instance.enable()
      return DataManager.instance.showUser().asDriver(onErrorDriveWith: .empty())
    }.map { _ in }
  }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
