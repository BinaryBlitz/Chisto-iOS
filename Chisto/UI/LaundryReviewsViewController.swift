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
import FloatRatingView

class LaundryReviewsViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: LaundryReviewsViewModel? = nil
  
  var dataSource = RxTableViewSectionedReloadDataSource<LaundryReviewsSectionModel>()
  
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
    laundryBackgroundImageView.kf.setImage(with: viewModel.laundryBackgroundUrl)
    laundryRatingView.rating = viewModel.laundryRating
    reviewsCountLabel.text = viewModel.laundryReviewsCountLabel
    
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
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = nil

  }
  
}
