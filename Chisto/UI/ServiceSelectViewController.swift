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
    navigationItem.title = viewModel?.navigationItemTitle
    
    itemTitle.text = viewModel?.itemTitle
    
    configureTableView()
    configureFooter()
    
    viewModel?.presentOrderSection.drive(onNext: { [weak self] in
      self?.navigationController?.setViewControllers([OrderViewController.storyboardInstance()!], animated: true)
    }).addDisposableTo(disposeBag)
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
    
    tableView.rx.itemDeselected
      .bindTo(viewModel.itemDidDeSelect)
      .addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
  }
  
  func configureFooter() {
    guard let viewModel = viewModel else { return }
    
    viewModel.selectedServicesIds.asObservable().map { $0.count > 0 }
      .bindTo(readyButton.rx.isEnabled)
      .addDisposableTo(disposeBag)
    
    readyButton.rx.tap.bindTo(viewModel.readyButtonTapped).addDisposableTo(disposeBag)

  }
  
  override func viewWillAppear(_ animated: Bool) {
    guard let color = viewModel?.color else { return }
    navigationController?.navigationBar.barTintColor = color
    headerView.backgroundColor = viewModel?.color
  }
}
