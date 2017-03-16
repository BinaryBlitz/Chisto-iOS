//
//  OrderReviewAlertViewController.swift
//  Chisto
//
//  Created by Алексей on 19.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import FloatRatingView
import TextFieldEffects
import RxSwift
import RxCocoa

class OrderReviewAlertViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: OrderReviewAlertViewModel? = nil

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var ratingView: FloatRatingView!
  @IBOutlet weak var reviewContentField: HoshiTextField!
  @IBOutlet weak var continueButton: GoButton!

  // Constants
  let animationDuration = 0.2

  override func viewDidLoad() {
    reviewContentField.inputAccessoryView = UIView()
    ratingView.delegate = self
    hideKeyboardWhenTappedAround()
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)

    guard let viewModel = viewModel else { return }

    titleLabel.text = viewModel.title
    (reviewContentField.rx.text <-> viewModel.reviewContent).addDisposableTo(disposeBag)
    ratingView.rating = Float(viewModel.ratingStarsCount.value)
    continueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)

    viewModel.uiEnabled.asObservable().bindTo(continueButton.rx.isEnabled).addDisposableTo(disposeBag)

    viewModel.dismissViewController.drive(onNext: { [weak self] in
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

extension OrderReviewAlertViewController: FloatRatingViewDelegate {
  func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
    viewModel?.ratingStarsCount.value = Int(rating)
  }
}
