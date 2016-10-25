//
//  OrderViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class OrderViewController: UIViewController, UIScrollViewDelegate,DefaultBarColoredViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var continueButton: GoButton!
  private let emptyOrderView = EmptyOrderView.nibInstance()
  
  private let viewModel = OrderViewModel()
  private let disposeBag = DisposeBag()
  var dataSource = RxTableViewSectionedReloadDataSource<OrderSectionModel>()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = viewModel.navigationBarTitle
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconUser"), style: .plain, target: nil, action: nil)
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    // Rx
    emptyOrderView?.addButton.rx.tap.bindTo(viewModel.emptyOrderAddButtonDidTap).addDisposableTo(disposeBag)
    navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.navigationAddButtonDidTap).addDisposableTo(disposeBag)
    continueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)
    
    viewModel.presentCategoriesViewController.drive(onNext: {
      let viewController = CategoriesViewController.storyboardInstance()!
      self.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentItemInfoViewController.drive(onNext: { [weak self] viewModel in
      let viewController = ItemInfoViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentLastTimeOrderPopup.drive(onNext: { [weak self] viewModel in
      let viewController = LastTimePopupViewController.storyboardInstance()!
      viewController.modalPresentationStyle = .overFullScreen
      self?.present(viewController, animated: false, completion: nil)

    }).addDisposableTo(disposeBag)
    
    configureTableView()
    
  }
  
  func configureTableView() {
    // UI
    tableView.backgroundView = emptyOrderView
    
    // Bindings
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
      
      cell.configure(viewModel: cellViewModel)
      return cell
    }
    
    viewModel.currentOrderItems.asDriver().drive(onNext: { [weak self] items in
      if items.count > 0 {
        self?.continueButton.isEnabled = true
        self?.tableView.separatorStyle = .singleLine
        self?.tableView.backgroundView?.isHidden = true
      } else {
        self?.continueButton.isEnabled = false
        self?.tableView.separatorStyle = .none
        self?.tableView.backgroundView?.isHidden = false
      }
    }).addDisposableTo(disposeBag)
    
    tableView.delegate = nil
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)
    
    tableView.rx.itemSelected
      .bindTo(viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(tableView.rx.items(dataSource: dataSource))
      .addDisposableTo(self.disposeBag)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }

}
