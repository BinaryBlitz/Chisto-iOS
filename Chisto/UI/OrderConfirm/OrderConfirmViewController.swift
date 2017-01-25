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

  var viewModel: OrderConfirmViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<OrderConfirmSectionModel>()

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var confirmButton: GoButton!
  @IBOutlet weak var laundryBackgroundImageView: UIImageView!
  @IBOutlet weak var laundryLogoImageView: UIImageView!
  @IBOutlet weak var laundryDecriptionLabel: UILabel!
  @IBOutlet weak var laundryRatingsCountLabel: UILabel!
  @IBOutlet weak var laundryRatingView: FloatRatingView!
  @IBOutlet weak var collectionDateLabel: UILabel!
  @IBOutlet weak var collectionTimeLabel: UILabel!
  @IBOutlet weak var deliveryDateLabel: UILabel!
  @IBOutlet weak var deliveryTimeLabel: UILabel!


  let tableHeaderView = OrderConfirmTableHeaderView.nibInstance()!

  override func viewDidLoad() {
    navigationItem.title = viewModel?.navigationBarTitle
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    configureHeader()
    configureNavigations()
    configureFooter()
    configureTableView()
  }

  func configureHeader() {
    guard let viewModel = viewModel else { return }
    laundryDecriptionLabel.text = viewModel.laundryDescriprionTitle
    laundryLogoImageView.kf.setImage(with: viewModel.laundryIcon)
    collectionTimeLabel.text = viewModel.collectionTime
    deliveryTimeLabel.text = viewModel.deliveryTime
    laundryRatingView.rating = viewModel.laundryRating
    laundryRatingsCountLabel.text = viewModel.ratingsCountText
    collectionDateLabel.text = viewModel.collectionDate
    deliveryDateLabel.text = viewModel.deliveryDate

    let backgroundProcessor = OverlayImageProcessor(overlay: .black, fraction: 0.7)
    laundryBackgroundImageView.kf.setImage(with: viewModel.laundryBackground, options: [.processor(backgroundProcessor)])

  }
  
  func configureNavigations() {
    viewModel?.presentRegistrationSection.drive(onNext: { viewModel in
      let registrationNavigationController = RegistrationNavigationController.storyboardInstance()!
      guard let registrationPhoneInputViewController = registrationNavigationController.viewControllers.first as? RegistrationPhoneInputViewController else { return }
      registrationPhoneInputViewController.viewModel = viewModel
      self.present(registrationNavigationController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    viewModel?.presentOrderContactDataSection.drive (onNext: { [weak self] in
      self?.navigationController?.pushViewController(OrderRegistrationViewController.storyboardInstance()!, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel?.presentLaundryReviewsSection.drive (onNext: { [weak self] viewModel in
      let viewController = LaundryReviewsViewController.storyboardInstance()!
      viewController.viewModel = viewModel
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)

    viewModel?.presentPromoCodeAlert.drive(onNext: { [weak self] viewModel in
      let viewController = PromoCodeAlertViewController.storyboardInstance()!
      viewController.modalPresentationStyle = .overFullScreen
      viewController.viewModel = viewModel
      self?.present(viewController, animated: false, completion: nil)
    }).addDisposableTo(disposeBag)
  }

  func configureFooter() {
    guard let viewModel = self.viewModel else { return }
    confirmButton.setTitle(viewModel.confirmOrderButtonTitle, for: .normal)
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
    tableHeaderView.configure(viewModel: viewModel.orderConfirmTableHeaderViewModel)
    tableView.tableHeaderView = tableHeaderView
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
  
  override func viewDidDisappear(_ animated: Bool) {
    navigationController?.navigationBar.isTranslucent = false
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
  
}
