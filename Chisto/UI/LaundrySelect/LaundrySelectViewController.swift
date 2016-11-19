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
    navigationItem.title = viewModel.navigationBarTitle
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconSortNavbar"), style: .plain, target: self, action: nil)
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.sortButtonDidTap)
      .addDisposableTo(disposeBag)

    viewModel.presentSortSelectSection.drive(onNext: {_ in
      let alertController = UIAlertController(title: "Сортировать химчистки по:", message: nil, preferredStyle: .alert)
      
      let byPriceAction = UIAlertAction(title: "По цене", style: .default, handler: { [weak self] _ in
        self?.viewModel.sortType.value = .byPrice
      })
      
      let bySpeedAction = UIAlertAction(title: "По скорости", style: .default, handler: { [weak self] _ in
        self?.viewModel.sortType.value = .bySpeed
      })
      
      let byRatingAction = UIAlertAction(title: "По рейтингу", style: .default, handler: { [weak self] _ in
        self?.viewModel.sortType.value = .byRating
      })
      
      let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
      
      alertController.addAction(byPriceAction)
      alertController.addAction(bySpeedAction)
      alertController.addAction(byRatingAction)
      alertController.addAction(cancelAction)
      
      self.present(alertController, animated: true)
    }).addDisposableTo(disposeBag)

    viewModel.presentOrderConfirmSection.drive(onNext: { orderViewModel in
      let viewController = OrderConfirmViewController.storyboardInstance()!
      viewController.viewModel = orderViewModel
      self.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)

    configureTableView()
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
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }

}
