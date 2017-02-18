//
//  CityNotFoundViewController.swift
//  Chisto
//
//  Created by Алексей on 12.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CityNotFoundViewController: UIViewController {
  let disposeBag = DisposeBag()
  let viewModel = CityNotFoundViewModel()

  // Constants
  let animationDuration = 0.2

  @IBOutlet weak var contentView: UIView!

  // Fields
  @IBOutlet weak var cityField: UITextField!
  @IBOutlet weak var phoneField: UITextField!

  let maskedPhoneField = MaskedInput(formattingType: .phoneNumber)

  // Footer
  let footerView = UIView()

  @IBOutlet weak var continueButton: GoButton!
  @IBOutlet weak var cancelButton: GoButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()

    cityField.delegate = self
    phoneField.delegate = self

    (cityField.rx.text <-> viewModel.cityTitle).addDisposableTo(disposeBag)
    (phoneField.rx.text <-> viewModel.phoneTitle).addDisposableTo(disposeBag)

    maskedPhoneField.configure(textField: phoneField)
    maskedPhoneField.isValid.asObservable().bindTo(viewModel.phoneIsValid).addDisposableTo(disposeBag)

    viewModel
      .continueButtonEnabled
      .asObservable()
      .bindTo(continueButton.rx.isEnabled)
      .addDisposableTo(disposeBag)

    view.backgroundColor = UIColor(white: 0, alpha: 0.5)

    contentView.clipsToBounds = true

    // Rx
    continueButton.rx
      .tap
      .bindTo(viewModel.continueButtonDidTap)
      .addDisposableTo(disposeBag)

    cancelButton.rx
      .tap
      .bindTo(viewModel.cancelButtonDidTap)
      .addDisposableTo(disposeBag)

    viewModel
      .dismissViewController
      .catchErrorAndContinue { error in
        guard let error = error as? DataError else { return }
        let alertController = UIAlertController(title: NSLocalizedString("error", comment: "Error alert"), message: error.description, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Error alert"), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
      }
      .subscribe(onNext: { [weak self] in
        UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
          self?.view.alpha = 0
        }, completion: { _ in
          self?.dismiss(animated: false, completion: nil)
        })
      })
      .addDisposableTo(disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }

}

extension CityNotFoundViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == cityField {
      phoneField.becomeFirstResponder()
      return false
    } else {
      return true
    }
  }

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {

    guard let text = textField.text, textField == phoneField else { return true }
    return maskedPhoneField.shouldContinueEditing(text: text, range: range, replacementStirng: string)
  }
}
