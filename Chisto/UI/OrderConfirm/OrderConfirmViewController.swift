//
//  OrderConfirmViewController.swift
//  Chisto
//
//  Created by Алексей on 01.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import FloatRatingView
import RxSwift
import RxDataSources
import RxCocoa
import Kingfisher

class OrderConfirmViewController: UIViewController, UITableViewDelegate {

  let disposeBag = DisposeBag()

  var viewModel : OrderConfirmViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<OrderConfirmSectionModel>()

  @IBOutlet weak var backgroundImageView: UIImageView!

  @IBOutlet weak var laundryDescriptionLabel: UILabel!
  @IBOutlet weak var laundryIconView: UIImageView!
  @IBOutlet weak var laundryRatingView: FloatRatingView!
  @IBOutlet weak var courierDateLabel: UILabel!
  @IBOutlet weak var laundryReviewsCountLabel: UILabel!
  @IBOutlet weak var deliveryDateLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var orderPriceLabel: UILabel!
  @IBOutlet weak var deliveryPriceLabel: UILabel!
  @IBOutlet weak var confirmButton: GoButton!

  override func viewDidLoad() {
    navigationItem.title = viewModel?.navigationBarTitle
    laundryDescriptionLabel.text = viewModel?.laundryDescriprionTitle
    laundryIconView.kf.setImage(with: viewModel?.laundryIcon)
    laundryRatingView.rating = viewModel?.laundryRating ?? 0
    courierDateLabel.text = viewModel?.courierDate
    deliveryDateLabel.text = viewModel?.deliveryDate
    backgroundImageView.kf.setImage(with: viewModel?.laundryBackground)

    viewModel?.presentRegistrationSection.drive(onNext: {
      self.present(RegistrationNavigationController.storyboardInstance()!, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)

    configureFooter()
    configureTableView()
  }

  func configureFooter() {
    guard let viewModel = self.viewModel else { return }
    confirmButton.rx.tap.bindTo(viewModel.confirmOrderButtonDidTap).addDisposableTo(disposeBag)
  }

  func configureTableView() {
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "OrderConfirmServiceTableViewCell", for: indexPath) as! OrderConfirmServiceTableViewCell

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

    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = nil
  }

}
