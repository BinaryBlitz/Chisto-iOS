//
//  ProfileContactDataViewController.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ProfileContactDataViewController: UIViewController {

  let disposeBag = DisposeBag()
  let viewModel = ProfileContactDataViewModel()

  @IBOutlet weak var formView: UIView!
  @IBOutlet weak var saveButton: GoButton!

  let contactFormViewController = ContactFormViewController.storyboardInstance()!

  override func viewDidLoad() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    viewModel.saveButtonIsEnabled.asObservable().bind(to: saveButton.rx.isEnabled).addDisposableTo(disposeBag)

    viewModel.presentCitySelectSection.drive(onNext: { [weak self] viewModel in
        let viewController = CitySelectViewController.storyboardInstance()!
        viewController.viewModel = viewModel
        self?.navigationController?.pushViewController(viewController, animated: true)
      }).addDisposableTo(disposeBag)

    saveButton.rx.tap.bind(to: viewModel.saveButtonDidTap).addDisposableTo(disposeBag)

    viewModel.popViewController.drive(onNext: { [weak self] in
        _ = self?.navigationController?.popViewController(animated: true)
      }).addDisposableTo(disposeBag)

    viewModel.presentLocationSelectSection.drive(onNext: { [weak self] viewModel in
        let viewController = LocationSelectViewController.storyboardInstance()!
        viewController.viewModel = viewModel
        self?.navigationController?.pushViewController(viewController, animated: true)
      }).addDisposableTo(disposeBag)

    configureForm()
  }

  func configureForm() {
    contactFormViewController.viewModel = viewModel.formViewModel
    addChildViewController(contactFormViewController)
    contactFormViewController.didMove(toParentViewController: self)
    formView.addSubview(contactFormViewController.view)
    contactFormViewController.view.frame = formView.bounds
  }

}
