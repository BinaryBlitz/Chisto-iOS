//
//  ContactDataTableHeaderView.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ContactFormTableHeaderView: UIView {
  let disposeBag = DisposeBag()
  @IBOutlet weak var iconButton: UIButton!
  @IBOutlet weak var labelButton: UIButton!
  
  func configure(viewModel: ContactFormTableHeaderViewModel) {
    iconButton.setImage(viewModel.icon, for: .normal)
    labelButton.setTitle(viewModel.title, for: .normal)
    labelButton.isEnabled = viewModel.isEnabled
    
    labelButton.rx.tap.bindTo(viewModel.buttonDidTap).addDisposableTo(disposeBag)
    iconButton.rx.tap.bindTo(viewModel.buttonDidTap).addDisposableTo(disposeBag)
  }
  
}
