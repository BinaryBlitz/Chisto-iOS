//
//  OnboardingStepVIewController.swift
//  Chisto
//
//  Created by Алексей on 26.05.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OnboardingStepViewController: UIViewController {
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var stepImageView: UIImageView!
  @IBOutlet weak var beginButton: GoButton!

  let disposeBag = DisposeBag()
  var beginButtonDidTap = PublishSubject<Void>()
  var beginButtonHidden: Bool = true

  var configuration: (image: UIImage, information: String)? = nil

  override func viewDidLoad() {
    guard let configuration = configuration else { return }
    descriptionLabel.text = configuration.information
    stepImageView.image = configuration.image
    beginButton.rx.tap.bind(to: beginButtonDidTap).addDisposableTo(disposeBag)
    beginButton.isHidden = beginButtonHidden
  }
}
