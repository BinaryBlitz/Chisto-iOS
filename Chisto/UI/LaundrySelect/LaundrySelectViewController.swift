//
//  LaundrySelectViewController.swift
//  Chisto
//
//  Created by Алексей on 26.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class LaundrySelectViewController: UITableViewController, DefaultBarColoredViewController {

  let disposeBag = DisposeBag()

  let viewModel = LaundrySelectViewModel()
  var dataSource = RxTableViewSectionedReloadDataSource<LaundrySelectSectionModel>()

  override func viewDidLoad() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconSortNavbar"), style: .plain, target: self, action: nil)
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.sortButtonDidTap)
      .addDisposableTo(disposeBag)

    viewModel.presentSortSelectSection.drive(onNext: { [weak self] _ in
      let alertController = UIAlertController(title: NSLocalizedString("laundrySorting", comment: "Laundry sorting alert"), message: nil, preferredStyle: .alert)
      
      let byPriceAction = UIAlertAction(title: NSLocalizedString("byPrice", comment: "Laundry sorting alert"), style: .default, handler: { _ in
        self?.viewModel.sortType.value = .byPrice
      })
      
      let bySpeedAction = UIAlertAction(title: NSLocalizedString("bySpeed", comment: "Laundry sorting alert"), style: .default, handler: { _ in
        self?.viewModel.sortType.value = .bySpeed
      })
      
      let byRatingAction = UIAlertAction(title: NSLocalizedString("byRating", comment: "Laundry sorting alert"), style: .default, handler: { _ in
        self?.viewModel.sortType.value = .byRating
      })
      
      let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Laundry sorting alert"), style: .cancel, handler: nil)

      alertController.addAction(byRatingAction)
      alertController.addAction(byPriceAction)
      alertController.addAction(bySpeedAction)
      alertController.addAction(cancelAction)
      
      self?.present(alertController, animated: true)
    }).addDisposableTo(disposeBag)

    viewModel.presentOrderConfirmSection.asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] orderViewModel in
      let viewController = OrderConfirmViewController.storyboardInstance()!
      viewController.viewModel = orderViewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)

    viewModel.presentLastTimeOrderPopup.asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { [weak self] popupViewModel in
        let viewController = LastTimePopupViewController.storyboardInstance()!

        viewController.viewModel = popupViewModel
        viewController.modalPresentationStyle = .overFullScreen
        self?.present(viewController, animated: false, completion: nil)
    }).addDisposableTo(disposeBag)

    viewModel.presentErrorAlert.asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] error in
      guard let error = error as? DataError else { return }
      let alertController = UIAlertController(title: "Ошибка", message: error.description, preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
      self?.present(alertController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)

    configureTableView()
  }

  func presentLastOrderPopupIfNeeded() {
    
  }

  func configureTableView() {
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "LaundrySelectTableViewCell", for: indexPath) as! LaundrySelectTableViewCell
      cell.configure(viewModel: cellViewModel)
      return cell
    }

    tableView.delegate = nil
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)

    tableView.rx.itemSelected
      .bindTo(viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)

    tableView.dataSource = nil
    viewModel.sections
      .drive(tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
  }

  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return !viewModel.sortedLaundries.value[indexPath.row].isDisabled
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }

}
