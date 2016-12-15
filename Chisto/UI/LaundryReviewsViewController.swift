//
//  LaundryReviewsViewController.swift
//  Chisto
//
//  Created by Алексей on 18.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources
import RxSwift
import Kingfisher
import FloatRatingView

class LaundryReviewsViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: LaundryReviewsViewModel? = nil
  
  var dataSource = RxTableViewSectionedReloadDataSource<LaundryReviewsSectionModel>()

  let emptyTableBackgroundView = EmptyTableBackgroundView.nibInstance()!
  @IBOutlet weak var laundryLogoView: UIImageView!
  @IBOutlet weak var laundryRatingView: FloatRatingView!
  @IBOutlet weak var laundryTitleLabel: UILabel!
  @IBOutlet weak var reviewsCountLabel: UILabel!
  @IBOutlet weak var laundryBackgroundImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    guard let viewModel = viewModel else { return }
    laundryTitleLabel.text = viewModel.laundryTitle
    laundryLogoView.kf.setImage(with: viewModel.laundryLogoUrl)
    let backgroundProcessor = OverlayImageProcessor(overlay: .black, fraction: 0.7)
    laundryBackgroundImageView.kf.setImage(with: viewModel.laundryBackgroundUrl, options: [.processor(backgroundProcessor)])
    laundryRatingView.rating = viewModel.laundryRating
    reviewsCountLabel.text = viewModel.laundryReviewsCountText
    
    viewModel.presentErrorAlert.asDriver(onErrorDriveWith: .empty()).drive(onNext: { error in
      guard let error = error as? DataError else { return }
      let alertController = UIAlertController(title: "Ошибка", message: error.description, preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
      self.present(alertController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    configureTableView()
  }
  
  func configureTableView() {
    emptyTableBackgroundView.title = "Нет отзывов"
    tableView.separatorStyle = .none
    tableView.backgroundView = emptyTableBackgroundView
    tableView.backgroundView?.isHidden = true
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(withIdentifier: "LaundryReviewsTableViewCell", for: indexPath) as! LaundryReviewsTableViewCell
      cell.configure(viewModel: cellViewModel)
      return cell
    }
    
    guard let viewModel = viewModel else { return }
    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)

    viewModel.tableIsEmpty.asDriver().drive(onNext: { [weak self] tableIsEmpty in
      self?.tableView.separatorStyle =  tableIsEmpty ? .none : .singleLine
      self?.tableView.backgroundView?.isHidden = tableIsEmpty ? false : true
    }).addDisposableTo(disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = nil

  }
  
}
