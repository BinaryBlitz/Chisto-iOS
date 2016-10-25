//
//  LastTimePopup.swift
//  Chisto
//
//  Created by Алексей on 24.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class LastTimePopupViewController: UIViewController {
  
  @IBOutlet weak var LaundryLogoImageView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet var contentView: UIView!
  
  var animationDuration = 0.2
  
  let viewModel = LastTimePopupViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.laundryDescriptionViewModels.enumerated().forEach { (counter, viewModel) in
      let laundryItemView = LaundryItemInfoView.nibInstance()!
      laundryItemView.configure(viewModel: viewModel)
      stackView.addArrangedSubview(laundryItemView)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }
}
