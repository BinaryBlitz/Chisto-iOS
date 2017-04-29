//
//  CategoriesViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class ClothesViewController: UITableViewController, DefaultBarColoredViewController {
  var searchController: UISearchController!
  var resultItemsController = SelectClothesViewController.storyboardInstance()!

  var dataSource = RxTableViewSectionedReloadDataSource<ItemsSectionModel>()
  let viewModel = ClothesViewModel()
  let disposeBag = DisposeBag()

  let headerView = CategoriesHeaderView.nibInstance()!

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: nil,
      action: nil
    )

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: #imageLiteral(resourceName:"iconNavbarClose"),
      style: .plain,
      target: nil,
      action: nil
    )

    navigationItem.leftBarButtonItem?.rx
      .tap
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)

    configureTableView()
    configureSearch()
    configureNavigations()
    headerView.viewModel = viewModel.headerViewModel
  }

  func configureNavigations() {
    viewModel
      .presentServicesSection
      .drive(onNext: { [weak self] viewModel in
        let viewController = ServiceSelectViewController.storyboardInstance()!
        viewController.viewModel = viewModel

        self?.navigationController?.pushViewController(viewController, animated: true)
      })
      .addDisposableTo(disposeBag)

    viewModel
      .presentErrorAlert
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { error in
        guard let error = error as? DataError else { return }

        let alertController = UIAlertController(
          title: NSLocalizedString("error", comment: "Error alert"),
          message: error.description,
          preferredStyle: .alert
        )

        let defaultAction = UIAlertAction(
          title: NSLocalizedString("OK", comment: "Error alert"),
          style: .default,
          handler: nil
        )

        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)
  }


  func configureSearch() {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.sizeToFit()
    searchController.delegate = self

    tableView.tableHeaderView = searchController.searchBar

    // UI
    definesPresentationContext = true

    let searchBar = searchController.searchBar

    searchController
      .searchBar
      .rx.text
      .bind(to: viewModel.searchBarString)
      .addDisposableTo(disposeBag)

    searchBar.barTintColor = UIColor.chsSkyBlue
    searchBar.layer.borderWidth = 1
    searchBar.layer.borderColor = UIColor.chsSkyBlue.cgColor
    searchBar.tintColor = UIColor.white
    searchBar.backgroundColor = UIColor.chsSkyBlue
    searchBar.backgroundImage = UIImage()
    searchBar.setSearchFieldBackgroundImage(#imageLiteral(resourceName:"searchBarTextBack"), for: .normal)
    searchBar.setImage(#imageLiteral(resourceName:"iconSearch"), for: .search, state: .normal)
    searchBar.setTextColor(color: UIColor.white)
    searchBar.searchTextPositionAdjustment = UIOffsetMake(5.0, 0.0)
  }

  func configureTableView() {
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension

    // Bindings
    dataSource.configureCell = { _, tableView, indexPath, cellViewModel in
      let cell = tableView.dequeueReusableCell(
        withIdentifier: "ItemTableViewCell",
        for: indexPath
      ) as! ItemTableViewCell

      cell.configure(viewModel: cellViewModel)
      return cell
    }

    tableView.delegate = nil

    tableView.rx
      .setDelegate(self)
      .addDisposableTo(disposeBag)

    tableView.rx
      .itemSelected
      .bind(to: viewModel.itemDidSelect)
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


  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerView
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 100
  }

}

extension ClothesViewController: UISearchControllerDelegate {
  func willPresentSearchController(_ searchController: UISearchController) {
    viewModel.didStartSearching.onNext()
  }
}
