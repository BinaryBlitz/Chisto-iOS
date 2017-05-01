//
//  ServiceSelectViewController.swift
//  Chisto
//
//  Created by Алексей on 19.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

class ServiceSelectViewController: UIViewController, UIScrollViewDelegate {

  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var itemTitle: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var readyButton: UIButton!

  let disposeBag = DisposeBag()

  var viewModel: ServiceSelectViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<ServiceSelectSectionModel>()

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    itemTitle.text = viewModel?.itemTitle

    configureTableView()
    configureFooter()

    viewModel?.showNewSection.asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] section in
        guard let `self` = self else { return }
        switch section {
        case .order:
          self.dismiss(animated: true, completion: nil)
        case .orderItem:
          _ = self.navigationController?.popViewController(animated: true)
        case .areaAlert(let viewModel):
          self.presentAreaAlert(viewModel: viewModel)
        }

      }).addDisposableTo(disposeBag)
  }

  func configureTableView() {
    tableView.estimatedRowHeight = 102
    tableView.rowHeight = UITableViewAutomaticDimension
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceSelectTableViewCell", for: indexPath) as! ServiceSelectTableViewCell
      cell.configure(viewModel: cellViewModel)
      if cellViewModel.isSelected {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      } else {
        tableView.deselectRow(at: indexPath, animated: false)
      }

      return cell
    }

    tableView.delegate = nil
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)

    guard let viewModel = viewModel else { return }

    tableView.rx.itemSelected
      .bind(to: viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)

    tableView.rx.itemDeselected
      .bind(to: viewModel.itemDidDeselect)
      .addDisposableTo(disposeBag)

    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
  }

  func configureFooter() {
    guard let viewModel = viewModel else { return }

    viewModel.selectedServicesIds.asObservable().map { $0.count > 0 }
      .bind(to: readyButton.rx.isEnabled)
      .addDisposableTo(disposeBag)

    readyButton.rx.tap.bind(to: viewModel.readyButtonTapped).addDisposableTo(disposeBag)

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let viewModel = viewModel else { return }
    navigationController?.navigationBar.barTintColor = viewModel.color
    headerView.backgroundColor = viewModel.color
  }

  func presentAreaAlert(viewModel: ItemSizeAlertViewModel) {
    let viewController = ItemSizeAlertViewController.storyboardInstance()!
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .overFullScreen
    present(viewController, animated: false, completion: nil)
  }

  func navigate(section: ServiceSelectViewModel.NewSection) {

  }

}
