//
//  ContactDataTableHeaderViewModel.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class ContactFormTableHeaderViewModel {

  let title: String
  let icon: UIImage
  let isEnabled = Variable<Bool>(true)

  let buttonDidTap = PublishSubject<Void>()
  let sendPromoCode = PublishSubject<Void>()
  let presentErrorAlert = PublishSubject<String>()
  var timer: Observable<Int>? = nil

  init(title: String, icon: UIImage) {
    self.title = title
    self.icon = icon
    buttonDidTap.asObservable()
      .filter { isEnabled.value }
      .map {

    }
  }

}
