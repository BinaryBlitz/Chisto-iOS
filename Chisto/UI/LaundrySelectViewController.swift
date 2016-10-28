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
  let viewModel = LaundrySelectViewModel()
  let disposeBag = DisposeBag()
  var dataSource = RxTableViewSectionedReloadDataSource<LaundrySelectSectionModel>()

  override func viewDidLoad() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconSortNavbar"), style: .plain, target: self, action: nil)
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
