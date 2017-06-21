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
  let disposeBag = DisposeBag()
  let title: String
  let icon: UIImage
  let buttonDidTap = PublishSubject<Void>()

  init(title: String, icon: UIImage) {
    self.title = title
    self.icon = icon
  }

}
