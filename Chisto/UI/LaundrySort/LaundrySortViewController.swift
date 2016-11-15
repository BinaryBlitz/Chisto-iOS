//
//  LaundrySortModalViewController.swift
//  Chisto
//
//  Created by Алексей on 28.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class LaundrySortViewController: UIViewController, UITableViewDelegate {

  let disposeBag = DisposeBag()

  var viewModel: LaundrySortViewModel? = nil
  var dataSource = RxTableViewSectionedReloadDataSource<LaundrySortSectionModel>()
  var animationDuration = 0.2

  @IBOutlet weak var tableView: UITableView!


  override func viewDidLoad() {
    configureTableView()

    viewModel?.dismissViewController.drive(onNext: { [weak self] in
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
        }, completion: { _ in
          self?.dismiss(animated: false, completion: nil)
      })
    }).addDisposableTo(disposeBag)
  }

  func configureTableView() {
    guard let viewModel = self.viewModel else { return }

    dataSource.configureCell = { _, tableView, indexPath, sortItem in
      let cell = tableView.dequeueReusableCell(withIdentifier: "LaundrySortTableViewCell", for: indexPath)
      cell.textLabel?.text = sortItem.title
      return cell
    }

    tableView.delegate = nil
    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)

    tableView.rx.itemSelected
      .bindTo(viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)

    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)

  }

  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }

}
