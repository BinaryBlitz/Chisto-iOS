//
//  OrderInfoViewController.swift
//  Chisto
//
//  Created by Алексей on 20.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import FloatRatingView
import RxSwift
import RxDataSources
import RxCocoa
import Kingfisher

class OrderInfoViewController: UIViewController, UITableViewDelegate {
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var laundryLogoView: UIImageView!
  @IBOutlet weak var laundryTitleLabel: UILabel!
  @IBOutlet weak var laundryDescriptionLabel: UILabel!
  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var orderDateLabel: UILabel!
  @IBOutlet weak var orderStatusText: UILabel!
  @IBOutlet weak var orderStatusIconView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var orderPriceLabel: UILabel!
  @IBOutlet weak var deliveryPriceLabel: UILabel!
  @IBOutlet weak var orderTotalCostLabel: UILabel!
  
  @IBOutlet weak var supportButton: GoButton!
  var viewModel : OrderInfoViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<OrderInfoSectionModel>()
  
  override func viewDidLoad() {
    navigationItem.title = viewModel?.navigationBarTitle
    configureHeader()
    configureFooter()
    configureTableView()
  }
  
  func configureHeader() {
    laundryLogoView.kf.setImage(with: viewModel?.laundryIcon)
    laundryTitleLabel.text = viewModel?.laundryTitle
    laundryDescriptionLabel.text = viewModel?.laundryDescriprion
    orderStatusText.text = viewModel?.orderStatus
    orderStatusIconView.image = viewModel?.orderStatusIcon
    orderDateLabel.text = viewModel?.orderDate
    orderNumberLabel.text = viewModel?.orderNumber
    orderStatusText.textColor = viewModel?.orderStatusColor
  }
  
  func configureFooter() {
    guard let viewModel = viewModel else { return }
    viewModel.orderPrice.asObservable().bindTo(orderPriceLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.deliveryPrice.asObservable().bindTo(deliveryPriceLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.totalCost.asObservable().bindTo(orderTotalCostLabel.rx.text).addDisposableTo(disposeBag)
    supportButton.rx.tap.bindTo(viewModel.supportButtonDidTap).addDisposableTo(disposeBag)
  }
  
  func configureTableView() {
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "OrderInfoTableViewCell", for: indexPath) as! OrderInfoTableViewCell
      
      cell.configure(viewModel: cellViewModel)
      return cell
    }
    
    tableView.delegate = nil
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)
        
    tableView.dataSource = nil
    
    guard let viewModel = viewModel else { return }
    
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
    
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
}
  
