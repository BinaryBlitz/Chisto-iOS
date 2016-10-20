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
  @IBOutlet weak var tableView: UITableView!
  
  let disposeBag = DisposeBag()
  var viewModel: ServiceSelectViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<ServiceSelectSectionModel>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  func configureTableView() {
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceSelectTableViewCell", for: indexPath) as! ServiceSelectTableViewCell
      
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
  

}
