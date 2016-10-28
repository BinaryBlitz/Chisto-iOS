//
//  LastTimePopup.swift
//  Chisto
//
//  Created by Алексей on 24.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class LastTimePopupViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: LastTimePopupViewModel? = nil
  
  @IBOutlet weak var LaundryLogoImageView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var showAllLaundriesButton: GoButton!
  
  
  var animationDuration = 0.2
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let viewModel = self.viewModel else { return }
    
    viewModel.dismissViewController.drive(onNext: {
      self.dismiss(animated: false, completion: nil)
    }).addDisposableTo(disposeBag)
    
    for viewModel in viewModel.laundryDescriptionViewModels {
      let laundryItemView = LaundryItemInfoView.nibInstance()!
      laundryItemView.configure(viewModel: viewModel)
      stackView.addArrangedSubview(laundryItemView)
    }
    
    showAllLaundriesButton.rx.tap.bindTo(viewModel.showAllLaundriesButtonDidTap).addDisposableTo(disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }
}
