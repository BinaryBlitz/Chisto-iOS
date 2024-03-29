//
//  RegistrationPhoneInputViewController.swift
//  Chisto
//
//  Created by Алексей on 03.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift
import SafariServices

class RegistrationPhoneInputViewController: UIViewController {

  let disposeBag = DisposeBag()
  var viewModel: RegistrationPhoneInputViewModel? = nil

  @IBOutlet weak var phoneInputField: UITextField!
  @IBOutlet weak var sendButton: GoButton!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

  @IBOutlet weak var licenseAgreementLabel: UILabel!

  override func viewDidLoad() {
    hideKeyboardWhenTappedAround()
    licenseAgreementLabel.attributedText = viewModel?.licenseAgreementText

    IQKeyboardManager.shared
      .disabledDistanceHandlingClasses
      .append(RegistrationPhoneInputViewController.self)

    bottomLayoutConstraint.updateWithKeyboard()

    phoneInputField.inputAccessoryView = UIView()
    phoneInputField.tintColor = UIColor.chsSkyBlue

    navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: nil, action: nil
    )

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: #imageLiteral(resourceName:"iconNavbarClose"),
      style: .plain,
      target: nil, action: nil
    )

    navigationItem.leftBarButtonItem?.rx
      .tap.asDriver()
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: {})
      }).addDisposableTo(disposeBag)

    guard let viewModel = viewModel else { return }

    phoneInputField.rx
      .text
      .bind(to: viewModel.phoneText)
      .addDisposableTo(disposeBag)

    sendButton.rx
      .tap
      .bind(to: viewModel.sendButtonDidTap)
      .addDisposableTo(disposeBag)

    viewModel
      .presentCodeInputSection
      .catchErrorAndContinue { error in
        guard let error = error as? DataError else { return }

        self.present(self.alertController(forError: error), animated: true, completion: nil)
      }
      .subscribe(onNext: { [weak self] viewModel in
        let viewController = RegistrationCodeInputViewController.storyboardInstance()!
        viewController.viewModel = viewModel

        self?.navigationController?.pushViewController(viewController, animated: false)
      })
      .addDisposableTo(disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    phoneInputField.becomeFirstResponder()
    AnalyticsManager.logScreen(.registrationPhone)
  }

  @IBAction func licenseAgreementDidTap(_ sender: Any) {
    guard let url = viewModel?.termsOfServiceURL else { return }
    let safariViewController = SFSafariViewController(url: url)

    present(safariViewController, animated: true, completion: nil)
  }

  private func alertController(forError error: DataError) -> UIAlertController {
    let alertController = UIAlertController(
      title: NSLocalizedString("error", comment: "Error alert"),
      message: error.description,
      preferredStyle: .alert
    )

    let defaultAction = UIAlertAction(
      title: NSLocalizedString("OK", comment: "Error alert"),
      style: .default,
      handler: nil
    )

    alertController.addAction(defaultAction)

    return alertController
  }

}
