//
//  OrderRegistrationViewController.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OrderRegistrationViewController: UIViewController {
  let viewModel = OrderRegistrationViewModel()
  let disposeBag = DisposeBag()
  @IBOutlet weak var dataView: UIView!
  @IBOutlet weak var payWithCardButton: GoButton!
  @IBOutlet weak var payInCashButton: GoButton!
  @IBOutlet weak var orderCostLabel: UILabel!
  
  let contactFormViewController = ContactFormViewController.storyboardInstance()!
  
  override func viewDidLoad() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)
    
    navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(onNext: {[weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    orderCostLabel.text = viewModel.orderCost
    viewModel.buttonsAreEnabled.asObservable().bindTo(payInCashButton.rx.isEnabled).addDisposableTo(disposeBag)
    viewModel.buttonsAreEnabled.asObservable().bindTo(payWithCardButton.rx.isEnabled).addDisposableTo(disposeBag)
    payInCashButton.rx.tap.bindTo(viewModel.payInCashButtonDidTap).addDisposableTo(disposeBag)
    payWithCardButton.rx.tap.bindTo(viewModel.payWithCreditCardButtonDidTap).addDisposableTo(disposeBag)
    
    viewModel.presentCitySelectSection.drive(onNext: { [weak self] viewModel in
      let viewController = CitySelectViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentLocationSelectSection.drive(onNext: { [weak self] viewModel in
      let viewController = LocationSelectViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentOrderPlacedPopup.drive(onNext: { [weak self] viewModel in
      let viewController = OrderPlacedPopupViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      viewController.modalPresentationStyle = .overFullScreen
      self?.present(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.dismissViewController
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: {[weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)

    configureForm()
  }
  
  func configureForm() {
    contactFormViewController.viewModel = viewModel.formViewModel
    addChildViewController(contactFormViewController)
    contactFormViewController.didMove(toParentViewController: self)
    dataView.addSubview(contactFormViewController.view)
    contactFormViewController.view.frame = dataView.bounds
  }
}
