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

class RegistrationCodeInputViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: RegistrationCodeInputViewModel? = nil

  let maskedCodeInput = MaskedInput(formattingPattern: "*∙*∙*∙*", replacementChar: "*")

  @IBOutlet weak var codeField: UITextField!
  @IBOutlet weak var repeatButton: UIButton!
  @IBOutlet weak var subTitleLabel: UILabel!
  @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    navigationItem.title = viewModel?.navigationBarTitle
    bottomLayoutConstraint.updateWithKeyboard()
    IQLayoutGuideConstraint = bottomLayoutConstraint
    codeField.inputAccessoryView = UIView()
    codeField.tintColor = UIColor.chsSkyBlue

    subTitleLabel.text = viewModel?.subTitleText
    repeatButton.setAttributedTitle(viewModel?.resendLabelText, for: .normal)

    maskedCodeInput.configure(textField: codeField)

    guard let viewModel = viewModel else { return }

    codeField.rx.text.bindTo(viewModel.code).addDisposableTo(disposeBag)

    maskedCodeInput.isValid.asObservable().bindTo(viewModel.codeIsValid).addDisposableTo(disposeBag)

    viewModel.presentRegistrationScreen.drive(onNext: { [weak self] in
      self?.navigationController?.setViewControllers([OrderRegistrationViewController.storyboardInstance()!], animated: true)
    }).addDisposableTo(disposeBag)

  }
}
