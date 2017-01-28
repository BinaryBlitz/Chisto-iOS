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
  
  @IBOutlet weak var tableView: UITableView!
  let headerView = OrderInfoTableHeaderView.nibInstance()!
  let footerView = OrderInfoTableFooterView.nibInstance()!

  @IBOutlet weak var ratingButton: GoButton!
  var viewModel : OrderInfoViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<OrderInfoSectionModel>()
  
  override func viewDidLoad() {
    tableView.tableHeaderView = headerView

    guard let viewModel = self.viewModel else { return }
    navigationItem.title = viewModel.navigationBarTitle
    headerView.configure(viewModel: viewModel.orderInfoTableHeaderViewModel)
    footerView.configure(phone: viewModel.phoneNumber)

    ratingButton.rx.tap.bindTo(viewModel.ratingButtonDidTap).addDisposableTo(disposeBag)
    configureTableView()
    
    footerView.phoneLabelDidTap
      .asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] in
      let alertController = UIAlertController(title: nil, message: viewModel.phoneNumber, preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
      let callAction = UIAlertAction(title: "call".localized, style: .default, handler: { [weak self] _ in
        guard let phoneNumber = self?.viewModel?.phoneNumber.onlyDigits else { return }
        guard let url = URL(string: "tel://+\(phoneNumber)") else { return }
        UIApplication.shared.openURL(url)
      })
      alertController.addAction(cancelAction)
      alertController.addAction(callAction)
      self?.present(alertController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)

    viewModel.presentRatingAlert.asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] viewModel in
      let viewController = OrderReviewAlertViewController.storyboardInstance()!
      viewController.modalPresentationStyle = .overFullScreen

      viewController.viewModel = viewModel
      self?.present(viewController, animated: false, completion: nil)
    }).addDisposableTo(disposeBag)
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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let headerView = tableView.tableHeaderView!
    headerView.setNeedsLayout()
    headerView.layoutIfNeeded()
    let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    var frame = headerView.frame
    frame.size.height = height
    headerView.frame = frame
    tableView.tableHeaderView = headerView
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return footerView
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 83
  }
  
}
  
