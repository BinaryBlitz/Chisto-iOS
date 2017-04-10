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

    viewModel.buttonIsHidden.asObservable().bind(to: logoutButton.rx.isHidden).addDisposableTo(disposeBag)
    viewModel.dismissViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(disposeBag)
    viewModel.presentOnboardingScreen.drive(onNext: { [weak self] in
      self?.dismiss(animated: true, completion: {
        RootViewController.instance?.present(OnBoardingNavigationController.storyboardInstance()!, animated: true, completion: nil)
      })
    }).addDisposableTo(disposeBag)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName:"iconNavbarClose"), style: .plain, target: nil, action: nil)
    navigationItem.leftBarButtonItem?.rx.tap.bind(to: viewModel.navigationCloseButtonDidTap).addDisposableTo(disposeBag)

    logoutButton.rx.tap.bind(to: viewModel.logoutButtonDidTap).addDisposableTo(disposeBag)
  }
}
