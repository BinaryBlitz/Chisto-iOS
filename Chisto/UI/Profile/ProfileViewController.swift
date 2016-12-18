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
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    tableView.tableFooterView = UIView()

    navigationItem.leftBarButtonItem?.rx.tap.bindTo(viewModel.closeButtonDidTap)
      .addDisposableTo(disposeBag)

    tableView.rx.itemSelected.bindTo(viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)

    viewModel.dismissViewController.drive(onNext: { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)

    viewModel.presentAboutSection.drive(onNext: { [weak self] in
      let viewController = AboutViewController.storyboardInstance()!
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)

    viewModel.presentContactDataSection.drive(onNext: { [weak self] in
      let viewController = ProfileContactDataViewController.storyboardInstance()!
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentMyOrdersSection.drive(onNext: { [weak self] in
      let viewController = MyOrdersViewController.storyboardInstance()!
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentTermsOfServiceSection.drive(onNext: { [weak self] _ in
      guard let url = self?.viewModel.termsOfServiceURL else { return }
      let viewController = SFSafariViewController(url: url)
      viewController.delegate = self
      self?.present(viewController, animated: true, completion: {
        UIApplication.shared.statusBarStyle = .default
      })
    }).addDisposableTo(disposeBag)
    
    viewModel.ordersCount.asObservable().bindTo(ordersCountLabel.rx.text).addDisposableTo(disposeBag)
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
