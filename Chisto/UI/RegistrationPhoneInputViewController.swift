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

class RegistrationPhoneInputViewController: UIViewController {
  var disposeBag = DisposeBag()
  @IBOutlet weak var phoneInputField: MaskedTextField!
  @IBOutlet weak var sendButton: GoButton!
  override func viewDidLoad() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)
    
    navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(onNext: {[weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    phoneInputField.isValid.asObservable().bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
    
    sendButton.rx.tap.asDriver().drive(onNext: { [weak self] in
      guard let phoneText = self?.phoneInputField.text else { return }
      
      let viewModel = RegistrationCodeInputViewModel(phoneNumberString: phoneText)
      let viewController = RegistrationCodeInputViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.setViewControllers([viewController], animated: false)
    }).addDisposableTo(disposeBag)
  }
}
