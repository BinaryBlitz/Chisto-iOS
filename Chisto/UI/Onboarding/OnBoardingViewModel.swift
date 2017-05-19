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
  let nextButtonTitle = Variable<String>("")

  let presentCitySelectSection = PublishSubject<CitySelectViewModel>()
  let setNextViewController = PublishSubject<Int>()
  let dismissViewController: Driver<Void>

  let descriptionSteps: [(String, UIImage)] = [
    (title: NSLocalizedString("onboardingStep1", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum1")),
    (title: NSLocalizedString("onboardingStep2", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum2")),
    (title: NSLocalizedString("onboardingStep3", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum3")),
    (title: NSLocalizedString("onboardingStep4", comment: "Onboarding step"), icon: #imageLiteral(resourceName:"iconNum4"))
  ]

  init() {
    let cityDidSelected = PublishSubject<Void>()
    self.cityDidSelected = cityDidSelected
    self.dismissViewController = cityDidSelected.asDriver(onErrorDriveWith: .empty())

    let goButtonCurrentPageObservable = goButtonDidTap
      .asObservable()
      .map { self.currentPage.value }

    let setNextPage = PublishSubject<Int>()

    goButtonCurrentPageObservable.subscribe(onNext: { page in
      if page == self.descriptionSteps.count - 1 {
        let viewModel = CitySelectViewModel()
        viewModel.itemDidSelect.asObservable().map { _ in Void() }
          .bind(to: cityDidSelected)
          .addDisposableTo(viewModel.disposeBag)
        self.presentCitySelectSection.onNext(viewModel)
      } else {
        setNextPage.onNext(page + 1)
      }
    }).addDisposableTo(disposeBag)

    setNextPage
      .bind(to: currentPage)
      .addDisposableTo(disposeBag)

    setNextPage
      .bind(to: setNextViewController)
      .addDisposableTo(disposeBag)

    currentPage.asObservable().map {
      $0 == self.descriptionSteps.count - 1 ? NSLocalizedString("onboardingStartButtonTitle", comment: "Onboarding") : NSLocalizedString("onboardingNextButtonTitle", comment: "Onboarding")
    }.bind(to: nextButtonTitle).addDisposableTo(disposeBag)


  }
}
