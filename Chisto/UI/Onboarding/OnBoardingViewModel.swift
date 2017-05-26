//
//  OnBoardingViewModel.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol OnBoardingViewModelType {
  var goButtonDidTap: PublishSubject<Void> { get }

  var presentCitySelectSection: Driver<CitySelectViewModel> { get }
  var dismissViewController: Driver<Void> { get }
}

class OnBoardingViewModel {
  let disposeBag = DisposeBag()
  let goButtonDidTap = PublishSubject<Void>()
  let cityDidSelected: PublishSubject<Void>
  let currentPage = Variable<Int>(0)
  let pageControlHidden = Variable<Bool>(false)

  let presentCitySelectSection: Driver<CitySelectViewModel>
  let setNextViewController = PublishSubject<Int>()
  let dismissViewController: Driver<Void>

  let descriptionSteps: [(String, UIImage)] = [
    (title: NSLocalizedString("onboardingStep2", comment: "Onboarding step"), image: #imageLiteral(resourceName: "onboardingStep2")),
    (title: NSLocalizedString("onboardingStep3", comment: "Onboarding step"), icon: #imageLiteral(resourceName: "onboardingStep3")),
    (title: NSLocalizedString("onboardingStep4", comment: "Onboarding step"), icon: #imageLiteral(resourceName: "onboardingStep4"))
  ]

  init() {
    let cityDidSelected = PublishSubject<Void>()
    self.cityDidSelected = cityDidSelected
    self.dismissViewController = cityDidSelected.asDriver(onErrorDriveWith: .empty())

    self.presentCitySelectSection = goButtonDidTap
      .asDriver(onErrorDriveWith: .empty())
      .map {
        let viewModel = CitySelectViewModel()
        viewModel.itemDidSelect.asObservable().map { _ in Void() }
          .bind(to: cityDidSelected)
          .addDisposableTo(viewModel.disposeBag)
        return viewModel
    }

    currentPage.asObservable().map {
      $0 == self.descriptionSteps.count
    }.bind(to: pageControlHidden).addDisposableTo(disposeBag)


  }
}
