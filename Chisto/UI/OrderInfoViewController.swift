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
    
    guard let viewModel = viewModel else { return }
    viewModel.presentCallSupportAlert.drive(onNext: { [weak self] in
      let alertController = UIAlertController(title: nil, message: viewModel.phoneNumber, preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
      let callAction = UIAlertAction(title: "Позвонить", style: .default, handler: { [weak self] _ in
        guard let phoneNumber = self?.viewModel?.phoneNumber.onlyDigits else { return }
        guard let url = URL(string: "tel://+\(phoneNumber)") else { return }
        UIApplication.shared.openURL(url)
      })
      alertController.addAction(cancelAction)
      alertController.addAction(callAction)
      self?.present(alertController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
  }
  
  func configureHeader() {
    orderNumberLabel.text = viewModel?.orderNumber

    bindLaundryData()
    bindLaundryStatusData()
  }


  func bindLaundryData() {
    guard let viewModel = viewModel else { return }
    viewModel.laundryIcon.asObservable().subscribe(onNext: { [weak self] icon in
      self?.laundryLogoView.kf.setImage(with: icon)
    }).addDisposableTo(disposeBag)

    viewModel.laundryTitle.asObservable().bindTo(laundryTitleLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.laundryDescriprion.asObservable().bindTo(laundryDescriptionLabel.rx.text).addDisposableTo(disposeBag)
  }

  func bindLaundryStatusData() {
    guard let viewModel = viewModel else { return }
    viewModel.orderStatus.asObservable().bindTo(orderStatusText.rx.text).addDisposableTo(disposeBag)
    viewModel.orderDate.asObservable().bindTo(orderDateLabel.rx.text).addDisposableTo(disposeBag)

    viewModel.orderStatusIcon.asObservable().filter { $0 != nil }.map { $0! }
      .bindTo(orderStatusIconView.rx.image).addDisposableTo(disposeBag)

    viewModel.orderStatusColor.asObservable().subscribe(onNext: { [weak self] color in
      self?.orderStatusText.textColor = color
    }).addDisposableTo(disposeBag)

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
  
