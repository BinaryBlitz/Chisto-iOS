//
//  BadgeButton.swift
//  Chisto
//
//  Created by Алексей on 29.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BadgeButtonView: UIView {
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var badgeView: UIView!
  @IBOutlet weak var badgeLabel: UILabel!

  let tap = PublishSubject<Void>()

  @IBAction func headerViewDidTap(_ sender: Any) {
    tap.onNext()
  }

  @IBAction func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .began:
      button.isHighlighted = true
    case .ended:
      tap.onNext()
      button.isHighlighted = false
    case .cancelled:
      button.isHighlighted = false
    default:
      break
    }
  }
}
