//
//  UIViewController+transitionCompletionBlock.swift
//  Chisto
//
//  Created by Алексей on 12.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
  func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
    pushViewController(viewController, animated: animated)
    guard animated, let coordinator = transitionCoordinator else {
      completion()
      return
    }
    coordinator.animate(alongsideTransition: nil) { _ in completion() }
  }
}
