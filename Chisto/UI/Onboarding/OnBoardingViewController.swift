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

class OnBoardingViewController: UIViewController {
  let viewModel = OnBoardingViewModel()

  var pageViewController: UIPageViewController? = nil {
    didSet {
      pageViewController?.delegate = self
      pageViewController?.dataSource = self
    }
  }

  var stepViewControllers: [UIViewController] = [] {
    didSet {
      guard let firstViewController = stepViewControllers.first else { return }
      pageViewController?.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
    }
  }

  @IBOutlet weak var goButton: UIButton!

  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    goButton.rx.tap.bind(to: viewModel.goButtonDidTap).addDisposableTo(disposeBag)

    viewModel.nextButtonTitle
      .asObservable()
      .bind(to: goButton.rx.title())
      .addDisposableTo(disposeBag)

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
    let pageControl: UIPageControl = UIPageControl.appearance()
    pageControl.pageIndicatorTintColor = UIColor.chsSilver
    pageControl.currentPageIndicatorTintColor = UIColor.chsSlateGrey

    self.stepViewControllers = viewModel.descriptionSteps.map { title, icon in
      let descriptionListItemView = DescriptionListItemView.nibInstance()!
      descriptionListItemView.configure(countImage: icon, information: title)
      descriptionListItemView.translatesAutoresizingMaskIntoConstraints = false
      let viewController = UIViewController()

      viewController.view.addSubview(descriptionListItemView)
      descriptionListItemView.leftAnchor.constraint(equalTo: viewController.view.leftAnchor, constant: 15).isActive = true
      descriptionListItemView.rightAnchor.constraint(equalTo: viewController.view.rightAnchor, constant: -20).isActive = true
      descriptionListItemView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor).isActive = true

      viewController.view.updateConstraints()
      viewController.view.layoutIfNeeded()

      return viewController
    }

    viewModel.setNextViewController.subscribe(onNext: { [weak self] index in
      guard let `self` = self else { return }
      self.pageViewController?.setViewControllers([self.stepViewControllers[index]], direction: .forward, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "pageViewController" else { return }
    self.pageViewController = segue.destination as? UIPageViewController
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    AnalyticsManager.logScreen(.onboarding)
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
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

  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return stepViewControllers.count
  }

  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return viewModel.currentPage.value
  }

}
