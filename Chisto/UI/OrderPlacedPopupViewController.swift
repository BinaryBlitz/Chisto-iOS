//
//  OrderConfirmedPopupViewController.swift
//  Chisto
//
//  Created by Алексей on 13.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OrderPlacedPopupViewController: UIViewController {
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var continueButton: GoButton!
  
  let disposeBag = DisposeBag()
  var viewModel: OrderPlacedPopupViewModel? = nil
  
  // Constants
  let animationDuration = 0.2
  override func viewDidLoad() {
    super.viewDidLoad()
    
    orderNumberLabel.text = viewModel?.orderNumber
    
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    
    contentView.clipsToBounds = true
    
    guard let viewModel = viewModel else { return }
    
    // Rx
    continueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)
    
    viewModel.dismissViewController.drive(onNext: { [weak self] in
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
      }, completion: { _ in
        self?.dismiss(animated: false, completion: {
          viewModel.dismissParentViewController.onNext()
        })
      })
    }).addDisposableTo(disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }

}
