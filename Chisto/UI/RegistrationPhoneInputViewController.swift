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
  let maskedPhoneInput = MaskedInput(formattingPattern: "(***) *** ∙ ** ∙ **", replacementChar: "*")
  @IBOutlet weak var phoneInputField: UITextField!
  @IBOutlet weak var sendButton: GoButton!
  @IBOutlet weak var contentView: UIView!
  
  override func viewDidLoad() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)
    
    navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(onNext: {[weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    maskedPhoneInput.configure(textField: phoneInputField)
    
    maskedPhoneInput.isValid.asObservable().bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
    
    sendButton.rx.tap.asDriver().drive(onNext: { [weak self] in
      guard let phoneText = self?.phoneInputField.text else { return }
      
      let viewModel = RegistrationCodeInputViewModel(phoneNumberString: phoneText)
      let viewController = RegistrationCodeInputViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: false)
    }).addDisposableTo(disposeBag)
    
  }
}
