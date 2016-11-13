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

class RegistrationPhoneInputViewController: UIViewController {
  let disposeBag = DisposeBag()
  let viewModel = RegistrationPhoneInputViewModel()
  let maskedPhoneInput = MaskedInput(formattingPattern: "(***) *** ∙ ** ∙ **", replacementChar: "*")
  @IBOutlet weak var phoneInputField: UITextField!
  @IBOutlet weak var sendButton: GoButton!
  @IBOutlet weak var contentView: UIView!
  
  override func viewDidLoad() {
    hideKeyboardWhenTappedAround()
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)
    
    navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(onNext: {[weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    maskedPhoneInput.configure(textField: phoneInputField)
    
    maskedPhoneInput.isValid.asObservable().bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
    phoneInputField.rx.text.bindTo(viewModel.phoneText).addDisposableTo(disposeBag)
    
    sendButton.rx.tap.bindTo(viewModel.sendButtonDidTap).addDisposableTo(disposeBag)
    
    viewModel.presentCodeInputSection.subscribe(onNext: { [weak self] viewModel in
      let viewController = RegistrationCodeInputViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: false)
    }, onError: { error in
      let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
      self.present(alertController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
  }
}
