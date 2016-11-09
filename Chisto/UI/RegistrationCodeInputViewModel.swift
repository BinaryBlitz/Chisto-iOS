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
  let codeIsValid = Variable(false)
  let presentRegistrationScreen: Driver<Void>
  
  init(phoneNumberString: String) {
    self.subTitleText = "На номер +7 \(phoneNumberString) был отправлен код"
    self.resendLabelText = NSAttributedString(string: "Выслать повторно", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
    self.presentRegistrationScreen = codeIsValid.asObservable().filter { $0 == true }.map {_ in 
      let profile = ProfileManager.instance.userProfile
      try uiRealm.write {
        profile?.phone = "+7" + phoneNumberString.onlyDigits
      }
      return Void()
    }.asDriver(onErrorDriveWith: .empty())
    
  }
}
