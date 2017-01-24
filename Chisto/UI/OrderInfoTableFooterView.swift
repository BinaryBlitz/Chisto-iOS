//
//  OrderInfoTableFooterView.swift
//  Chisto
//
//  Created by Алексей on 22.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OrderInfoTableFooterView: UIView {
  var phoneLabelDidTap = PublishSubject<Void>()

  @IBAction func phoneDidTap(_ sender: Any) {
    phoneLabelDidTap.onNext()
  }

  @IBOutlet weak var phoneLabel: UILabel!

  func configure(phone: String) {
    phoneLabel.attributedText = NSAttributedString(string: phone, attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
  }
  
}
