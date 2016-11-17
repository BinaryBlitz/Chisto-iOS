//
//  RootViewController.swift
//  Chisto
//
//  Created by Алексей on 19.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxRealm

class RootViewController: ChistoNavigationController {

  let disposeBag = DisposeBag()

  override func viewDidAppear(_ animated: Bool) {
    let profileManager = ProfileManager.instance
    guard profileManager.userProfile.city == nil else { return }

    present(OnBoardingNavigationController.storyboardInstance()!, animated: true)
  }

  override func loadView() {
    super.loadView()
    OrderManager.instance.currentOrderItems.asObservable().subscribe(onNext: {[weak self] _ in
      self?.setViewControllers([OrderViewController.storyboardInstance()!], animated: true)
    }).addDisposableTo(disposeBag)
  }

}
