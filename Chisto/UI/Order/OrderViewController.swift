//
//  OrderViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class OrderViewController: UIViewController, DefaultBarColoredViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var continueButton: GoButton!
  private let emptyOrderView = EmptyOrderView.nibInstance()

  let viewModel = OrderViewModel()
  private let disposeBag = DisposeBag()
  var dataSource = RxTableViewSectionedReloadDataSource<OrderSectionModel>(configureCell: { _, tableView, indexPath, cellViewModel in
    let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
    
    cell.configure(viewModel: cellViewModel)
    return cell
  })

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = viewModel.navigationBarTitle

    emptyOrderView?.addButton.rx.tap.bind(to: viewModel.emptyOrderAddButtonDidTap)
      .addDisposableTo(disposeBag)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)

    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    navigationItem.rightBarButtonItem?.rx.tap.bind(to: viewModel.navigationAddButtonDidTap)
      .addDisposableTo(disposeBag)

    navigationItem.leftBarButtonItem?.rx
      .tap
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)

    continueButton.rx.tap.bind(to: viewModel.continueButtonDidTap)
      .addDisposableTo(disposeBag)

    viewModel.continueButtonEnabled.asObservable().bind(to: continueButton.rx.isEnabled).addDisposableTo(disposeBag)

    configureTableView()
    configureNavigations()

  }

  func configureTableView() {
    // UI
    tableView.backgroundView = emptyOrderView

    // Bindings
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell

      cell.configure(viewModel: cellViewModel)
      return cell
    }

    viewModel.currentOrderItems.asDriver().drive(onNext: { [weak self] items in
        if items.count > 0 {
          self?.continueButton.isEnabled = true
          self?.continueButton.titleLabel?.text = NSLocalizedString("continue", comment: "Order continue button title")
          self?.tableView.separatorStyle = .singleLine
          self?.tableView.backgroundView?.isHidden = true
        } else {
          self?.continueButton.isEnabled = false
          self?.continueButton.titleLabel?.text = NSLocalizedString("nothingIsChosenOrderScreen", comment: "No order items placeholder")
          self?.tableView.separatorStyle = .none
          self?.tableView.backgroundView?.isHidden = false
        }
      }).addDisposableTo(disposeBag)

    tableView.delegate = nil
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)

    tableView.rx.itemSelected
      .bind(to: viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)

    dataSource.canEditRowAtIndexPath = { _,_  in
      return true
    }

    tableView.rx.itemDeleted.bind(to: viewModel.tableItemDeleted)
      .addDisposableTo(disposeBag)


    tableView.dataSource = nil
    viewModel.sections
      .drive(tableView.rx.items(dataSource: dataSource))
      .addDisposableTo(self.disposeBag)

  }

  override func viewWillAppear(_ animated: Bool) {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
    AnalyticsManager.logScreen(.order)
  }

  func configureNavigations() {

    viewModel.presentCategoriesViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(disposeBag)

    viewModel.presentItemConfigurationViewController.drive(onNext: { [weak self] viewModel in
        let viewController = ItemConfigurationViewController.storyboardInstance()!
        viewController.viewModel = viewModel
      self?.navigationController?.present(ChistoNavigationController(rootViewController: viewController), animated: true)
      }).addDisposableTo(disposeBag)

    viewModel.presentLaundrySelectSection
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { [weak self] in
        let viewController = LaundrySelectViewController.storyboardInstance()!
        self?.navigationController?.pushViewController(viewController, animated: true) {
          viewController.viewModel.didFinishPushingViewController.onNext(())
        }
      })
      .addDisposableTo(disposeBag)
  }

}

extension OrderViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return viewModel.deleteButtonTitle
  }
}
