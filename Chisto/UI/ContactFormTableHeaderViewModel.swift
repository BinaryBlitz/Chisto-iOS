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
  let isEnabled: Bool
  
  let buttonDidTap = PublishSubject<Void>()
  
  init(title: String, icon: UIImage, isEnabledButton: Bool = false) {
    self.title = title
    self.icon = icon
    self.isEnabled = isEnabledButton
  }
}
