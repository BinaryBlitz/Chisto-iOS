//
//  OnBoardingViewController.swift
//  Chisto
//
//  Created by Алексей on 10.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OnBoardingViewController: UIPageViewController, DefaultBarColoredViewController {
  let viewModel = OnBoardingViewModel()
  var pageControl: UIPageControl!

  var stepViewControllers: [UIViewController] = [] {
    didSet {
      guard let firstViewController = stepViewControllers.first else { return }
      setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
    }
  }

  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    viewModel.dismissViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(disposeBag)

    viewModel.presentCitySelectSection
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { viewModel in
        let viewController = CitySelectViewController.storyboardInstance()!
        viewController.viewModel = viewModel
        self.navigationController?.pushViewController(viewController, animated: true)
      }).addDisposableTo(disposeBag)

    loadPageControllers()
  }

  func loadPageControllers() {
    delegate = self
    dataSource = self

    self.pageControl = UIPageControl(
      frame: CGRect(
        x: 0,
        y: self.view.frame.size.height - 50,
        width: self.view.frame.size.width,
        height: 50
      )
    )

    pageControl.pageIndicatorTintColor = UIColor.chsSilver
    pageControl.currentPageIndicatorTintColor = UIColor.chsSlateGrey

    self.view.addSubview(pageControl)

    var stepViewControllers: [UIViewController] = []
    stepViewControllers.append(OnboardingMainViewController.storyboardInstance()!)

    stepViewControllers += viewModel.descriptionSteps.map { title, image in
      let viewController = OnboardingStepViewController.storyboardInstance()!
      viewController.configuration = (image: image, information: title)
      return viewController
    }

    self.stepViewControllers = stepViewControllers

    pageControl.numberOfPages = stepViewControllers.count
    pageControl.currentPage = 0
    pageControl.isEnabled = false

    viewModel.currentPage
      .asObservable()
      .bind(to: pageControl.rx.currentPage)
      .addDisposableTo(disposeBag)

    viewModel
      .pageControlHidden
      .asObservable()
      .bind(to: pageControl.rx.isHidden)
      .addDisposableTo(disposeBag)

    if let viewController = stepViewControllers.last as? OnboardingStepViewController {
      viewController.beginButtonHidden = false
      viewController
        .beginButtonDidTap
        .asObservable()
        .bind(to: viewModel.goButtonDidTap)
        .addDisposableTo(disposeBag)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    UIApplication.shared.isStatusBarHidden = true
    AnalyticsManager.logScreen(.onboarding)
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    UIApplication.shared.isStatusBarHidden = false
  }

}

extension OnBoardingViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard let viewController = pageViewController.viewControllers?.last, completed else { return }
    viewModel.currentPage.value = stepViewControllers.index(of: viewController) ?? 0
  }
}

extension OnBoardingViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = stepViewControllers.index(of: viewController), index > 0 else {
      return nil
    }
    return stepViewControllers[index - 1]
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = stepViewControllers.index(of: viewController), index < stepViewControllers.count - 1 else {
      return nil
    }
    return stepViewControllers[index + 1]
  }
}
