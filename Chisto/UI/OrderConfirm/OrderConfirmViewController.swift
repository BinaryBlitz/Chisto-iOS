//
//  OrderConfirmViewController.swift
//  Chisto
//
//  Created by Алексей on 01.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import FloatRatingView
import RxSwift
import RxDataSources
import RxCocoa
import Kingfisher

class OrderConfirmViewController: UIViewController, UITableViewDelegate {

  let disposeBag = DisposeBag()

  var viewModel: OrderConfirmViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<OrderConfirmSectionModel>()

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var confirmButton: GoButton!

  let headerView = OrderConfirmTableHeaderView.nibInstance()!

  override func viewDidLoad() {
    navigationItem.title = viewModel?.navigationBarTitle
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    configureNavigations()
    configureFooter()
    configureTableView()
  }
  
  func configureNavigations() {
    viewModel?.presentRegistrationSection.drive(onNext: { viewModel in
      let registrationNavigationController = RegistrationNavigationController.storyboardInstance()!
      guard let registrationPhoneInputViewController = registrationNavigationController.viewControllers.first as? RegistrationPhoneInputViewController else { return }
      registrationPhoneInputViewController.viewModel = viewModel
      self.present(registrationNavigationController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    viewModel?.presentOrderContactDataSection.drive (onNext: { [weak self] in
      self?.navigationController?.pushViewController(OrderRegistrationViewController.storyboardInstance()!, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel?.presentLaundryReviewsSection.drive (onNext: { [weak self] viewModel in
      let viewController = LaundryReviewsViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)

    viewModel?.presentPromoCodeAlert.drive(onNext: { [weak self] viewModel in
      let viewController = PromoCodeAlertViewController.storyboardInstance()!
      viewController.modalPresentationStyle = .overFullScreen
      viewController.viewModel = viewModel
      self?.present(viewController, animated: false, completion: nil)
    }).addDisposableTo(disposeBag)
  }

  func configureFooter() {
    guard let viewModel = self.viewModel else { return }
    confirmButton.setTitle(viewModel.confirmOrderButtonTitle, for: .normal)
    confirmButton.rx.tap.bindTo(viewModel.confirmOrderButtonDidTap).addDisposableTo(disposeBag)
  }

  func configureTableView() {
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "OrderConfirmServiceTableViewCell", for: indexPath) as! OrderConfirmServiceTableViewCell

      cell.configure(viewModel: cellViewModel)
      return cell
    }
    tableView.delegate = nil
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)

    guard let viewModel = viewModel else { return }
    headerView.configure(viewModel: viewModel.orderConfirmTableHeaderViewModel)
    tableView.tableHeaderView = headerView

    tableView.rx.itemSelected
      .bindTo(viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)

    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)

    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = nil
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    navigationController?.navigationBar.isTranslucent = false
  }
  
}
