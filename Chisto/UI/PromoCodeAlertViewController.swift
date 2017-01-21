//
//  PromoCodeAlertViewController.swift
//  Chisto
//
//  Created by Алексей on 21.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PromoCodeAlertViewController: UIViewController {
  var viewModel: PromoCodeAlertViewModel? = nil
  let disposeBag = DisposeBag()

  let animationDuration = 0.2

  @IBOutlet weak var promoCodeField: UITextField!
  @IBOutlet weak var discountLabel: UILabel!
  @IBOutlet weak var continueButton: GoButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)

    guard let viewModel = viewModel else { return }

    (promoCodeField.rx.text <-> viewModel.promoCodeText).addDisposableTo(disposeBag)

    continueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)

    viewModel.dismissViewController.drive(onNext: { [weak self] success in
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
      }, completion: { _ in
        self?.dismiss(animated: false, completion: nil)
      })
    }).addDisposableTo(disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }
}
