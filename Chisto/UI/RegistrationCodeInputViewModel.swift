//
//  RegistrationCodeInputViewModel.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class RegistrationCodeInputViewModel {
  let subTitleText: String
  let resendLabelText: NSAttributedString
  
  init(phoneNumberString: String) {
    self.subTitleText = "На номер +7 \(phoneNumberString) был отправлен код"
    self.resendLabelText = NSAttributedString(string: "Выслать повторно", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
    
  }
}
