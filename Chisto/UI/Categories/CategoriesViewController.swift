//
//  CategoriesViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class CategoriesViewController: UIViewController, DefaultBarColoredViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var dataSource = RxTableViewSectionedReloadDataSource<CategoriesSectionModel>()
  let viewModel = CategoriesViewModel()
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = viewModel.navigationBarTitle
    
    configureTableView()
  }
  
  func configureTableView() {
    
    // Bindings
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
      
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
    
    viewModel.presentItemsSection.drive(onNext: { [weak self] viewModel in
      // @TODO use a more elegant way of getting VC from storyboard, e.g. method in a class
      let storyboard = UIStoryboard(name: "SelectClothes", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "SelectClothesTableViewController") as! SelectClothesTableViewController
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
  }

}

extension CategoriesViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }

}
