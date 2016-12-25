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
  private(set) static var instance: RootViewController? = nil
  let disposeBag = DisposeBag()

  override func viewDidAppear(_ animated: Bool) {
    let profileManager = ProfileManager.instance
    guard profileManager.userProfile.value.city == nil else { return }

    present(OnBoardingNavigationController.storyboardInstance()!, animated: true)
  }

  override func loadView() {
    RootViewController.instance = self
    super.loadView()
  }

}
