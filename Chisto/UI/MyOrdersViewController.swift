//
//  MyOrdersViewController.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class MyOrdersViewController: UITableViewController, DefaultBarColoredViewController {
  let disposeBag = DisposeBag()
  let dataSource = RxTableViewSectionedReloadDataSource<MyOrdersSectionModel>()
  var viewModel = MyOrdersViewModel()
  
  override func viewDidLoad() {
    navigationItem.title = viewModel.navigationBarTitle
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    configureTableView()
    
    viewModel.presentOrderInfoSection.drive(onNext: { [weak self] viewModel in
      let viewController = OrderInfoViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
  }
  
  func configureTableView() {
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrdersTableViewCell", for: indexPath) as! MyOrdersTableViewCell
      cell.configure(viewModel: cellViewModel)
      return cell
    }
    
    tableView.rx.itemSelected.bindTo(viewModel.itemDidSelect).addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
  }

  
}
