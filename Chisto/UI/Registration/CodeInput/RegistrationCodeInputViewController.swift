//
//  RegistrationCodeInputViewController.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import IQKeyboardManagerSwift
import SafariServices

class RegistrationCodeInputViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: RegistrationCodeInputViewModel? = nil

  let maskedCodeInput = MaskedInput(formattingType: .pattern("* ∙ * ∙ * ∙ * ∙ *"))

  @IBOutlet weak var codeField: UITextField!
  @IBOutlet weak var repeatButton: UIButton!
  @IBOutlet weak var subTitleLabel: UILabel!
  @IBOutlet weak var licenseAgreementLabel: UILabel!

  @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    hideKeyboardWhenTappedAround()
    licenseAgreementLabel.attributedText = viewModel?.licenseAgreementText
    IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(RegistrationCodeInputViewController.self)
    bottomLayoutConstraint.updateWithKeyboard()
    codeField.inputAccessoryView = UIView()
    codeField.tintColor = UIColor.chsSkyBlue

    subTitleLabel.text = viewModel?.subTitleText
    repeatButton.setAttributedTitle(viewModel?.resendLabelText, for: .normal)

    maskedCodeInput.configure(textField: codeField)

    guard let viewModel = viewModel else { return }

    codeField.rx.text.bind(to: viewModel.code).addDisposableTo(disposeBag)

    maskedCodeInput.isValid.asObservable().bind(to: viewModel.codeIsValid).addDisposableTo(disposeBag)

    viewModel.dismissViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: {
          viewModel.didFinishRegistration.onNext()
        })
      }).addDisposableTo(disposeBag)

  }

  override func viewWillAppear(_ animated: Bool) {
    codeField.becomeFirstResponder()
    AnalyticsManager.logScreen(.registrationCode)
  }

  @IBAction func licenseAgreementDidTap(_ sender: Any) {
    guard let url = viewModel?.termsOfServiceURL else { return }
    let safariViewController = SFSafariViewController(url: url)
    present(safariViewController, animated: true, completion: nil)

  }

}
