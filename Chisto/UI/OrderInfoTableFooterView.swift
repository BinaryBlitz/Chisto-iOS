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
    phoneLabelDidTap.onNext(())
  }

  @IBOutlet weak var phoneLabel: UILabel!

  func configure(phone: String) {
    phoneLabel.attributedText = NSAttributedString(string: phone, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle): NSUnderlineStyle.single.rawValue]))
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
