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
import Crashlytics

private let headerHeight: CGFloat = 100

class ClothesViewController: UIViewController, DefaultBarColoredViewController {
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
  
  var searchController: UISearchController!

  var dataSource = RxTableViewSectionedReloadDataSource<ItemsSectionModel>(configureCell: { _, tableView, indexPath, cellViewModel in
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "ItemTableViewCell",
      for: indexPath
      ) as! ItemTableViewCell
    
    cell.configure(viewModel: cellViewModel)
    return cell
  })
  let viewModel = ClothesViewModel()
  let disposeBag = DisposeBag()

  @IBOutlet weak var headerView: CategoriesHeaderView!
  let badgeButton = BadgeButtonView.nibInstance()!

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: nil,
      action: nil
    )

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: #imageLiteral(resourceName:"iconUser"),
      style: .plain,
      target: nil,
      action: nil
    )
    
    navigationItem.leftBarButtonItem?.rx.tap
      .bind(to: viewModel.profileButtonDidTap)
      .addDisposableTo(disposeBag)
    
    configureBadge()
    configureTableView()
    configureSearch()
    configureNavigations()
    headerView.viewModel = viewModel.headerViewModel
  }

  func configureBadge() {
    viewModel.currentItemsCount
      .asObservable()
      .map { $0 > 0 ? "\($0)" : "" }
      .bind(to: badgeButton.badgeLabel.rx.text)
      .addDisposableTo(disposeBag)

    viewModel.currentItemsCount
      .asObservable()
      .map { $0 == 0 }
      .bind(to: badgeButton.badgeView.rx.isHidden)
      .addDisposableTo(disposeBag)

    badgeButton.tap.bind(to: viewModel.basketButtonDidTap).addDisposableTo(disposeBag)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: badgeButton)
  }

  func configureNavigations() {
    viewModel
      .presentServicesSection
      .drive(onNext: { [weak self] viewModel in
        let viewController = ItemConfigurationViewController.storyboardInstance()!
        viewController.viewModel = viewModel

        self?.present(ChistoNavigationController(rootViewController: viewController), animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)

    viewModel.presentOrderScreen
      .drive(onNext: { [weak self] in
        self?.present(ChistoNavigationController(rootViewController: OrderViewController.storyboardInstance()!), animated: true, completion: nil)
    })
    .addDisposableTo(disposeBag)

    viewModel.presentProfileSection
      .drive(onNext: { [weak self] in
        let viewController = ProfileNavigationController.storyboardInstance()!
        self?.present(viewController, animated: true, completion: nil)
      })
      .addDisposableTo(disposeBag)

    viewModel.presentRatingSection
      .drive(onNext: { [weak self] viewModel in
        let viewController = OrderReviewAlertViewController.storyboardInstance()!
        viewController.modalPresentationStyle = .overFullScreen

        viewController.viewModel = viewModel
        self?.present(viewController, animated: false, completion: nil)
      })
      .addDisposableTo(disposeBag)

    viewModel.presentRatingAlert.asDriver(onErrorDriveWith: .empty()).drive(onNext: { [weak self] viewModel in
      let viewController = OrderReviewAlertViewController.storyboardInstance()!
      viewController.modalPresentationStyle = .overFullScreen

      viewController.viewModel = viewModel
      self?.present(viewController, animated: false, completion: nil)
    }).addDisposableTo(disposeBag)


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
    searchController = UISearchController(searchResultsController: nil)
    searchController.delegate = self

    // UI
    definesPresentationContext = true
    extendedLayoutIncludesOpaqueBars = true
    searchController?.dimsBackgroundDuringPresentation = false
    searchController?.hidesNavigationBarDuringPresentation = false
    //edgesForExtendedLayout = UIRectEdge([])

    let searchBar = searchController.searchBar

    searchBar.barTintColor = UIColor.chsSkyBlue
    searchBar.layer.borderWidth = 1
    searchBar.layer.borderColor = UIColor.chsSkyBlue.cgColor
    searchBar.tintColor = UIColor.white
    searchBar.backgroundColor = UIColor.chsSkyBlue
    searchBar.backgroundImage = UIImage()
    searchBar.setSearchFieldBackgroundImage(#imageLiteral(resourceName:"searchBarTextBack"), for: .normal)
    searchBar.setImage(#imageLiteral(resourceName:"iconSearch"), for: .search, state: .normal)
    searchBar.setTextColor(color: UIColor.white)
    searchBar.searchTextPositionAdjustment = UIOffset.init(horizontal: 5.0, vertical: 0.0)

    searchController
      .searchBar
      .rx.text
      .bind(to: viewModel.searchBarString)
      .addDisposableTo(disposeBag)

    searchController.searchBar.rx
      .cancelButtonClicked
      .map { "" }
      .bind(to: viewModel.searchBarString)
      .addDisposableTo(disposeBag)

    searchBar.sizeToFit()
    searchView.addSubview(searchBar)
  }

  func configureTableView() {
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableView.automaticDimension

    viewModel.categoriesUpdated
      .asObservable()
      .subscribe(onNext: { [weak self] in
        self?.tableView.reloadData()
        self?.headerView.collectionView.reloadData()
    }).addDisposableTo(disposeBag)

    viewModel.currentCategory
      .asObservable()
      .subscribe(onNext: { [weak self] _ in
        let indexPath = IndexPath(row: 0, section: 0)
        guard self?.tableView.cellForRow(at: indexPath) != nil else { return }
        self?.tableView.beginUpdates()
        self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        self?.tableView.endUpdates()
      }).addDisposableTo(disposeBag)

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
      headerView.scrollToSelectedRowIfNeeded()
      tableView.deselectRow(at: indexPath, animated: true)
    }
    AnalyticsManager.logScreen(.clothes)
    viewModel.fetchItemsIfNeeded()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}

extension ClothesViewController: UISearchControllerDelegate {
  func willPresentSearchController(_ searchController: UISearchController) {
    viewModel.didStartSearching.onNext(())

    UIView.animate(withDuration: 0.2) { [weak self] in
      self?.headerViewTopConstraint.constant -= headerHeight
      self?.view.layoutIfNeeded()
    }
  }

  func willDismissSearchController(_ searchController: UISearchController) {
    viewModel.didFinishSearching.onNext(())
    UIView.animate(withDuration: 0.2) { [weak self] in
      self?.headerViewTopConstraint.constant += headerHeight
    }
    headerView.scrollToSelectedRowIfNeeded()
  }
}

extension ClothesViewController: UITableViewDelegate {

}
