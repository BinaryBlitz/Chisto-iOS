//
//  SelectClothesTableViewController.swift
//  Chisto
//
//  Created by Алексей on 17.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class SelectClothesViewController: UITableViewController {

  let disposeBag = DisposeBag()

  var viewModel: SelectClothesViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<SelectClothesSectionModel>()

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = viewModel?.navigationBarTitle
    navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: nil,
      action: nil
    )

    viewModel?.presentSelectServiceSection
      .drive(onNext: { [weak self] viewModel in
        let viewController = ServiceSelectViewController.storyboardInstance()!
        viewController.viewModel = viewModel

        self?.navigationController?.pushViewController(viewController, animated: true)
      })
      .addDisposableTo(disposeBag)

    configureAlerts()
    configureTableView()
  }

  func configureAlerts() {
    viewModel?
      .presentHasDecorationAlert
      .drive(onNext: { [weak self] viewModel in
        let viewController = UIAlertController(
          title: viewModel.decorationAlertTitle,
          message: viewModel.decorationAlertMessage,
          preferredStyle: .alert
        )

        let yesAction = UIAlertAction(
          title: NSLocalizedString("yes", comment: "Decoration alert"),
          style: .default,
          handler: { _ in viewModel.yesButtonDidTap.onNext() }
        )

        let noAction = UIAlertAction(
          title: NSLocalizedString("no", comment: "Decoration alert"),
          style: .default,
          handler: { _ in viewModel.noButtonDidTap.onNext() }
        )

        let disableAction = UIAlertAction(
          title: NSLocalizedString("doNotShowAlertAgain", comment: "Decoration alert"),
          style: .default,
          handler: { _ in viewModel.disableAlertButtonDidTap.onNext() }
        )

        viewController.addAction(yesAction)
        viewController.addAction(noAction)
        viewController.addAction(disableAction)

        self?.present(viewController, animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)

    viewModel?
      .presentErrorAlert
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { error in
        guard let error = error as? DataError else { return }

        let alertController = UIAlertController(
          title: "Ошибка",
          message: error.description,
          preferredStyle: .alert
        )

        let defaultAction = UIAlertAction(
          title: "OK",
          style: .default,
          handler: nil
        )

        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)

    viewModel?.presentSlowItemAlert
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { [weak self] in
        let alert = UIAlertController(title: nil, message: NSLocalizedString("slowItemDesctiption", comment: "Slow item alert"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("okSlowItemAlert", comment: "Slow item alert"), style: .default, handler: nil))
        self?.present(alert, animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)
  }

  func configureTableView() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 103
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "SelectClothesTableViewCell", for: indexPath) as! SelectClothesTableViewCell

      cell.configure(viewModel: cellViewModel)
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

    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }

    if let color = viewModel?.navigationBarColor {
      navigationController?.navigationBar.barTintColor = color
    }
  }

}
