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

class ItemInfoViewController: UIViewController {
  @IBOutlet weak var clothesItemTitleLabel: UILabel!
  @IBOutlet weak var clothesItemRelatedLabel: UILabel!
  @IBOutlet weak var addServiceButton: UIButton!
  @IBOutlet weak var counterLabel: UILabel!
  @IBOutlet weak var counterIncButton: UIButton!
  @IBOutlet weak var counterDecButton: UIButton!
  @IBOutlet weak var continueButton: GoButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerView: UIView!
  
  let disposeBag = DisposeBag()
  var viewModel: ItemInfoViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<ItemInfoSectionModel>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    clothesItemTitleLabel.text = viewModel?.itemTitle
    clothesItemRelatedLabel.attributedText = viewModel?.itemRelatedText
    
    viewModel?.currentAmount.asObservable().map { String($0) }
      .bindTo(counterLabel.rx.text)
      .addDisposableTo(disposeBag)
    
    configureTableView()
    configureButtons()
    
    viewModel?.presentServiceSelectSection.drive(onNext: { [weak self] viewModel in
      let viewController = ServiceSelectViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel?.returnToOrderList.drive(onNext: { [weak self] in
      _ = self?.navigationController?.popViewController(animated: true)
    }).addDisposableTo(disposeBag)
    
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
    
    addServiceButton.rx.tap.bindTo(viewModel.addServiceButtonDidTap).addDisposableTo(disposeBag)
    continueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)
    counterIncButton.rx.tap.bindTo(viewModel.counterIncButtonDidTap).addDisposableTo(disposeBag)
    counterDecButton.rx.tap.bindTo(viewModel.counterDecButtonDidTap).addDisposableTo(disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    guard let color = viewModel?.color else { return }
    
    navigationController?.navigationBar.barTintColor = color
    headerView.backgroundColor = viewModel?.color
  }
}

extension ItemInfoViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return viewModel?.deleteButtonTitle
  }
}
