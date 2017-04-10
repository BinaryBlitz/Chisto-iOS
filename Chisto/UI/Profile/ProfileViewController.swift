//
//  ProfileViewController.swift
//  Chisto
//
//  Created by Алексей on 28.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit
import SafariServices

class ProfileViewController: UITableViewController {
  @IBOutlet weak var ordersCountLabel: UILabel!

  let disposeBag = DisposeBag()
  let viewModel = ProfileViewModel()

  override func viewDidLoad() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName:"iconNavbarClose"), style: .plain, target: nil, action: nil)
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    navigationItem.leftBarButtonItem?.rx.tap.bind(to: viewModel.closeButtonDidTap)
      .addDisposableTo(disposeBag)

    tableView.rx.itemSelected.bind(to: viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)

    viewModel.ordersCount.asObservable().bind(to: ordersCountLabel.rx.text).addDisposableTo(disposeBag)

    configureNavigations()
  }

  func configureNavigations() {
    viewModel.presentNextScreen.asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] newScreen in
        guard let `self` = self else { return }
        let viewController: UIViewController
        switch newScreen {
        case .contactData:
          viewController = ProfileContactDataViewController.storyboardInstance()!
        case .aboutApp:
          viewController = AboutViewController.storyboardInstance()!
        case .myOrders:
          viewController = MyOrdersViewController.storyboardInstance()!
        case .terms:
          let url = self.viewModel.termsOfServiceURL
          let safariViewController = SFSafariViewController(url: url)
          safariViewController.delegate = self
          viewController = safariViewController
        }
        guard newScreen == .terms else {
          self.navigationController?.pushViewController(viewController, animated: true)
          return
        }
        self.present(viewController, animated: true, completion: {
          UIApplication.shared.statusBarStyle = .default
        })
      }).addDisposableTo(disposeBag)

    viewModel.presentRegistrationSection.drive(onNext: { viewModel in
        let registrationNavigationController = RegistrationNavigationController.storyboardInstance()!
        guard let registrationPhoneInputViewController = registrationNavigationController.viewControllers.first as? RegistrationPhoneInputViewController else { return }
        registrationPhoneInputViewController.viewModel = viewModel
        self.present(registrationNavigationController, animated: true, completion: nil)
      }).addDisposableTo(disposeBag)

    viewModel.dismissViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(disposeBag)
  }

  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    view.tintColor = UIColor.chsWhiteTwo
  }

  override func viewWillAppear(_ animated: Bool) {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }

}

extension ProfileViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    UIApplication.shared.statusBarStyle = .lightContent
  }
}
