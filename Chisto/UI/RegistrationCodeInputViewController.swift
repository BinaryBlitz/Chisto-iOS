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

class RegistrationCodeInputViewController: UIViewController {
  let disposeBag = DisposeBag()
  let maskedCodeInput = MaskedInput(formattingPattern: "* ∙ * ∙ * ∙ * ∙ *", replacementChar: "*")
  var viewModel: RegistrationCodeInputViewModel? = nil
  @IBOutlet weak var codeField: UITextField!
  @IBOutlet weak var repeatButton: UIButton!
  @IBOutlet weak var subTitleLabel: UILabel!
  
  override func viewDidLoad() {
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)
    
    navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(onNext: {[weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)

    subTitleLabel.text = viewModel?.subTitleText
    repeatButton.setAttributedTitle(viewModel?.resendLabelText, for: .normal)
    
    maskedCodeInput.configure(textField: codeField)
    
    maskedCodeInput.isValid.asDriver().filter{$0 == true}.drive(onNext: { [weak self] _ in
      self?.navigationController?.pushViewController(OrderRegistrationViewController.storyboardInstance()!, animated: true)
    })
    
  }
}
