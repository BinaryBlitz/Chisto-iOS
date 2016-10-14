//
//  CategoriesViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy
import RxDataSources
import RxSwift

class CategoriesViewController: UIViewController, UIScrollViewDelegate {
  
  var dataSource = RxTableViewSectionedReloadDataSource<CategoriesSectionModel>()
  let viewModel = CategoriesViewModel()
  let disposeBag = DisposeBag()
  let tableView = UITableView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = viewModel.navigationBarTitle
    
    configureTableView()
  }
  
  func configureTableView() {
    // UI
    tableView.backgroundColor = UIColor.chsWhite
    tableView.bounces = false
    tableView.alwaysBounceVertical = false
    
    view.addSubview(tableView)
    tableView <- [
      Edges()
    ]
    
    tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
    
    // Bindings
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
      
      cell.configure(viewModel: cellViewModel)
      return cell
    }
    
    tableView.delegate = nil
    tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
    
    tableView.rx.itemSelected.bindTo(viewModel.itemDidSelect).addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
    
  }
}

extension CategoriesViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
}
