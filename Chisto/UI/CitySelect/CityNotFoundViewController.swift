//
//  CityNotFoundViewController.swift
//  Chisto
//
//  Created by Алексей on 12.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CityNotFoundViewController: UIViewController {
  let disposeBag = DisposeBag()
  let viewModel = CityNotFoundViewModel()
  
  // Constants
  let animationDuration = 0.2
  
  @IBOutlet weak var contentView: UIView!
  
  // Fields
  @IBOutlet weak var cityField: UITextField!
  @IBOutlet weak var phoneField: UITextField!

  // Footer
  let footerView = UIView()
  
  @IBOutlet weak var continueButton: GoButton!
  
  @IBOutlet weak var cancelButton: GoButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    
    self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    
    contentView.layer.cornerRadius = 8
    contentView.clipsToBounds = true
    
    contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {() -> Void in
      self.contentView.transform = CGAffineTransform.identity
    })

    
    // Rx
    continueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)
    cancelButton.rx.tap.bindTo(viewModel.cancelButtonDidTap).addDisposableTo(disposeBag)
    
    viewModel.dismissViewController.drive(onNext: { [weak self] in
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
        }, completion: { _ in
          self?.dismiss(animated: false, completion: nil)
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
