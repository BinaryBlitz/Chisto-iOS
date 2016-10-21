//
//  ItemInfoViewController.swift
//  Chisto
//
//  Created by Алексей on 21.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ItemInfoViewController: UIViewController, DefaultBarColoredViewController, UITableViewDelegate {
  @IBOutlet weak var clothesItemTitleLabel: UILabel!
  
  @IBOutlet weak var clothesItemRelatedLabel: UILabel!
  
  @IBOutlet weak var addServiceButton: UIButton!
  
  @IBOutlet weak var counterLabel: UILabel!
  
  @IBOutlet weak var counterIncButton: UIButton!
  
  @IBOutlet weak var counterDecButton: UIButton!
  
  @IBOutlet weak var continueButton: GoButton!
  
  @IBOutlet weak var tableView: UITableView!
  
  let disposeBag = DisposeBag()
  var viewModel: ItemInfoViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<ItemInfoSectionModel>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    clothesItemTitleLabel.text = viewModel?.itemTitle
    clothesItemRelatedLabel.attributedText = viewModel?.itemRelatedText
    
    viewModel?.currentAmount.asObservable().map { String($0) }
      .bindTo(counterLabel.rx.text)
      .addDisposableTo(disposeBag)
    
    configureTableView()
    configureButtons()
  }
  
  func configureTableView() {
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "ItemInfoTableViewCell", for: indexPath) as! ItemInfoTableViewCell
      
      cell.configure(viewModel: cellViewModel)
      
      return cell
    }
    
    dataSource.canEditRowAtIndexPath = { _ in
      return true
    }
    
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)
        
    guard let viewModel = viewModel else { return }
    
    tableView.rx.itemDeleted.bindTo(viewModel.tableItemDeleted)
      .addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(tableView.rx.items(dataSource: dataSource))
      .addDisposableTo(disposeBag)
  }
  
  func configureButtons() {
    guard let viewModel = viewModel else { return }
    
    counterIncButton.rx.tap.bindTo(viewModel.counterIncButtonDidTap).addDisposableTo(disposeBag)
    counterDecButton.rx.tap.bindTo(viewModel.counterDecButtonDidTap).addDisposableTo(disposeBag)

  }
}
