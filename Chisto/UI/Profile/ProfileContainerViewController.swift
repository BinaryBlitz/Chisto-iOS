//
//  ProfileContainerViewController.swift
//  Chisto
//
//  Created by Алексей on 20.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ProfileContainerViewController: UIViewController {
  let disposeBag = DisposeBag()
  let viewModel = ProfileContainerViewModel()

  @IBOutlet weak var logoutButton: GoButton!

  override func viewDidLoad() {

    viewModel.buttonIsHidden.asObservable().bindTo(logoutButton.rx.isHidden).addDisposableTo(disposeBag)
    viewModel.dismissViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(disposeBag)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName:"iconNavbarClose"), style: .plain, target: nil, action: nil)
    navigationItem.leftBarButtonItem?.rx.tap.bindTo(viewModel.navigationCloseButtonDidTap).addDisposableTo(disposeBag)

    logoutButton.rx.tap.bindTo(viewModel.logoutButtonDidTap).addDisposableTo(disposeBag)
  }
}
