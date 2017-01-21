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

class OrderRegistrationViewController: UIViewController, DefaultBarColoredViewController {

  let disposeBag = DisposeBag()
  let viewModel = OrderRegistrationViewModel()

  @IBOutlet weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
  @IBOutlet weak var dataView: UIView!
  @IBOutlet weak var payButton: GoButton!
  @IBOutlet weak var orderCostLabel: UILabel!
  @IBOutlet weak var buttonsView: UIView!
  
  let contactFormViewController = ContactFormViewController.storyboardInstance()!

  override func viewDidLoad() {
    navigationItem.title = "Регистрация"
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    orderCostLabel.text = viewModel.orderCost
    viewModel.buttonsAreEnabled.asObservable().bindTo(payButton.rx.isEnabled).addDisposableTo(disposeBag)
    payButton.rx.tap.bindTo(viewModel.payButtonDidTap).addDisposableTo(disposeBag)

    viewModel.presentLocationSelectSection.drive(onNext: { [weak self] viewModel in
      let viewController = LocationSelectViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentErrorAlert.asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] error in
      guard let error = error as? DataError else { return }
      let alertController = UIAlertController(title: "Ошибка", message: error.description, preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
      self?.present(alertController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentOrderPlacedPopup.drive(onNext: { [weak self] viewModel in
      let orderViewController = OrderViewController.storyboardInstance()!
      _ = self?.navigationController?.pushViewController(orderViewController, animated: true, completion: {
        let viewController = OrderPlacedPopupViewController.storyboardInstance()!
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .overFullScreen
        orderViewController.present(viewController, animated: false)
      })
    }).addDisposableTo(disposeBag)
    
    viewModel.presentPaymentSection.drive(onNext: { [weak self] viewModel in
      let navigationPaymentController = PaymentNavigationController.storyboardInstance()!
      let viewController = navigationPaymentController.viewControllers.first as! PaymentViewController
      viewController.viewModel = viewModel
      self?.present(navigationPaymentController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)

    configureForm()
  }

  func configureForm() {
    contactFormViewController.viewModel = viewModel.formViewModel
    addChildViewController(contactFormViewController)
    contactFormViewController.didMove(toParentViewController: self)
    dataView.addSubview(contactFormViewController.view)
    contactFormViewController.view.frame = dataView.bounds
    contactFormViewController.cityButton.isEnabled = false
    contactFormViewController.cityField.textColor = UIColor.chsSilver
  }

}
