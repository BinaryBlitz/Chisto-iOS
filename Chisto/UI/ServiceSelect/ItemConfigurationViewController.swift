//
//  ItemConfigurationViewController.swift
//  Chisto
//
//  Created by Алексей on 29.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ItemConfigurationViewController: UIViewController {
  @IBOutlet weak var itemDescriptionLabel: UILabel!
  @IBOutlet weak var counterLabel: UILabel!
  @IBOutlet weak var saveButton: GoButton!
  @IBOutlet weak var incButton: UIButton!
  @IBOutlet weak var decButton: UIButton!
  @IBOutlet weak var headerView: UIView!
  
  var viewModel: ItemConfigurationViewModel!

  var tableVC: ItemConfigurationTableViewController? = nil {
    didSet {
      tableVC?.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    headerView.backgroundColor = viewModel.color
    navigationItem.title = viewModel.itemTitle
    itemDescriptionLabel.text = viewModel.itemDescription

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: #imageLiteral(resourceName:"iconNavbarClose"),
      style: .plain, target: nil,
      action: nil
    )

    navigationItem.leftBarButtonItem?.rx.tap
      .bind(to: viewModel.dismiss)
      .addDisposableTo(viewModel.disposeBag)

    saveButton.rx.tap
      .bind(to: viewModel.saveButtonTapped)
      .addDisposableTo(viewModel.disposeBag)

    incButton.rx.tap
      .bind(to: viewModel.counterIncButtonTapped)
      .addDisposableTo(viewModel.disposeBag)

    decButton.rx.tap
      .bind(to: viewModel.counterDecButtonTapped)
      .addDisposableTo(viewModel.disposeBag)

    viewModel.currentAmount
      .asObservable()
      .map { "\($0)" }
      .bind(to: counterLabel.rx.text)
      .addDisposableTo(viewModel.disposeBag)

    viewModel
      .saveButtonIsEnabled
      .asObservable()
      .bind(to: saveButton.rx.isEnabled)
      .addDisposableTo(viewModel.disposeBag)

    viewModel.dismiss
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(viewModel.disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.barTintColor = viewModel.color
    headerView.backgroundColor = viewModel.color
    AnalyticsManager.logScreen(.itemInfo)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "tableContainerSegue" else { return }
    self.tableVC = segue.destination as? ItemConfigurationTableViewController
  }
}
