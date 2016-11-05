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
import Kingfisher

class LastTimePopupViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: LastTimePopupViewModel? = nil
  
  @IBOutlet weak var backgroundLaundryImageView: UIImageView!
  @IBOutlet weak var laundryLogoImageView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var showAllLaundriesButton: GoButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  var animationDuration = 0.2
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let viewModel = self.viewModel else { return }
    
    titleLabel.text = viewModel.title
    descriptionLabel.text = viewModel.laundryDescription
    laundryLogoImageView.kf.setImage(with: viewModel.laundryLogoUrl)
    backgroundLaundryImageView.kf.setImage(with: viewModel.laundryBackgroundUrl)
    
    viewModel.dismissViewController.drive(onNext: { [weak self] in
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
        }, completion: { _ in
          self?.dismiss(animated: false, completion: nil)
      })
    }).addDisposableTo(disposeBag)
    
    for viewModel in viewModel.laundryDescriptionViewModels {
      let laundryItemView = LaundryItemInfoView.nibInstance()!
      laundryItemView.backgroundColor = UIColor.white
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
