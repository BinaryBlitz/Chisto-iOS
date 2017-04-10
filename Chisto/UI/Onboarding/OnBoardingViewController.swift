//
//  OnBoardingViewController.swift
//  Chisto
//
//  Created by Алексей on 10.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift

class OnBoardingViewController: UIViewController {
  let viewModel = OnBoardingViewModel()

  let descriptionSteps: [(String, UIImage)] = [
    (title: NSLocalizedString("onboardingStep1", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum1")),
    (title: NSLocalizedString("onboardingStep2", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum2")),
    (title: NSLocalizedString("onboardingStep3", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum3")),
    (title: NSLocalizedString("onboardingStep4", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum4"))
  ]

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var goButton: UIButton!

  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    goButton.rx.tap.bind(to: viewModel.goButtonDidTap).addDisposableTo(disposeBag)

    viewModel.dismissViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(disposeBag)

    viewModel.presentCitySelectSection.drive(onNext: { viewModel in
        let viewController = CitySelectViewController.storyboardInstance()!
        viewController.viewModel = viewModel
        self.navigationController?.pushViewController(viewController, animated: true)
      }).addDisposableTo(disposeBag)

    for (title, icon) in descriptionSteps {
      if let descriptionListItemView = DescriptionListItemView.nibInstance() {
        descriptionListItemView.configure(countImage: icon, information: title)
        stackView.addArrangedSubview(descriptionListItemView)
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
}
