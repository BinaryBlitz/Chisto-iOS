//
//  RegistrationCodeInputViewController.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class RegistrationCodeInputViewController: UIViewController {
  var viewModel: RegistrationCodeInputViewModel? = nil
  @IBOutlet weak var codeField: MaskedTextField!
  @IBOutlet weak var repeatButton: UIButton!
  @IBOutlet weak var subTitleLabel: UILabel!
  
  override func viewDidLoad() {
    subTitleLabel.text = viewModel?.subTitleText
    repeatButton.setAttributedTitle(viewModel?.resendLabelText, for: .normal)
    
  }
}
