//
//  HasDecorationAlertViewController.swift
//  Chisto
//
//  Created by Алексей on 05.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class HasDecorationAlertViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: HasDecorationAlertViewModel? = nil
  let animationDuration = 0.2

  @IBOutlet weak var yesButton: GoButton!
  @IBOutlet weak var noButton: GoButton!
  
  
  override func viewDidLoad() {
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    guard let viewModel = viewModel else { return }

    yesButton.rx.tap.bindTo(viewModel.yesButtonDidTap).addDisposableTo(disposeBag)
    noButton.rx.tap.bindTo(viewModel.noButtonDidTap).addDisposableTo(disposeBag)
    
    viewModel.dismissViewController.drive(onNext: { [weak self] in
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
      }, completion: self?.dismissAnimationDidComplete)
    }).addDisposableTo(disposeBag)
  }

  func dismissAnimationDidComplete (_ success: Bool) {
    guard let viewModel = viewModel else { return }
    dismiss(animated: false, completion: {
      viewModel.didFinishAlert.onNext(viewModel.orderItem)
    })
  }

  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }
}
