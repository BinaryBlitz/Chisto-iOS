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
    
    configureTableView()
  }
  
  func configureTableView() {
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
      .bindTo(viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let color = viewModel?.navigationBarColor {
      navigationController?.navigationBar.barTintColor = color
    }
  }
}
