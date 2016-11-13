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

class RegistrationPhoneInputViewModel {
  let presentCodeInputSection: Observable<RegistrationCodeInputViewModel>
  let sendButtonDidTap = PublishSubject<Void>()
  let phoneText: Variable<String?>
  
  init() {
    let phoneText = Variable<String?>(nil)
    self.phoneText = phoneText
    
    self.presentCodeInputSection = sendButtonDidTap.asObservable().flatMap { _ -> Observable<RegistrationCodeInputViewModel> in
      guard let phoneText = phoneText.value else { return Observable.error(DataError.unknown) }
      return DataManager.instance.createVerificationToken(phone: "+7" + phoneText.onlyDigits).map {
        return RegistrationCodeInputViewModel(phoneNumberString: phoneText)
      }
    }
  }
}
