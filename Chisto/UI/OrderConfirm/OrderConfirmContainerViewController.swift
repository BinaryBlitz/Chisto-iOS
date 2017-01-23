//
//  OrderConfirmContainerViewController.swift
//  Chisto
//
//  Created by Алексей on 22.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class OrderConfirmContainerViewController: UIViewController {
  var viewModel: OrderConfirmViewModel? = nil

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "segueContainer") {
      let viewController = segue.destination as! OrderConfirmViewController
      viewController.viewModel = viewModel
    }
  }

}
