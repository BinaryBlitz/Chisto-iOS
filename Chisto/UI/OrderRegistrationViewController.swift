//
//  OrderRegistrationViewController.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class OrderRegistrationViewController: UIViewController {
  @IBOutlet weak var dataView: UIView!
  @IBOutlet weak var payWithCardButton: GoButton!
  @IBOutlet weak var payInCashButton: GoButton!
  @IBOutlet weak var orderCostLabel: UILabel!
  
  let contactFormViewController = ContactFormViewController.storyboardInstance()!
  
  override func viewDidLoad() {
    configureForm()
  }
  
  func configureForm() {
    let formViewModel = ContactFormViewModel()
    contactFormViewController.viewModel = formViewModel
    addChildViewController(contactFormViewController)
    contactFormViewController.didMove(toParentViewController: self)
    dataView.addSubview(contactFormViewController.view)
    contactFormViewController.view.frame = dataView.bounds
  }
}
