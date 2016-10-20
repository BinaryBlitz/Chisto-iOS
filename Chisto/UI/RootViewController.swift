//
//  RootViewController.swift
//  Chisto
//
//  Created by Алексей on 19.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class RootViewController: ChistoNavigationController {

  override func viewDidAppear(_ animated: Bool) {
    guard UserDefaults.standard.value(forKey: "userCity") == nil else { return }

    present(OnBoardingNavigationController.storyboardInstance()!, animated: true)
  }

}
