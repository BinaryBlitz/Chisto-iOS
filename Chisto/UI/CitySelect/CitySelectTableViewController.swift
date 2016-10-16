//
//  CitySelectTableViewController.swift
//  Chisto
//
//  Created by Алексей on 11.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class CitySelectTableViewController: UIViewController {
  let searchController = UISearchController(searchResultsController: nil)
  
  @IBOutlet weak var goButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  var dataSource = RxTableViewSectionedReloadDataSource<CitySelectSectionModel>()
  private let viewModel = CitySelectViewModel()
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavigationBar()
    configureTableView()
    configureSearch()
    configureFooter()
    
    viewModel.presentCityNotFoundController.drive(onNext: { [weak self] in
      let storyboard = UIStoryboard(name: "CityNotFound", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "CityNotFoundViewController") as! CityNotFoundViewController
      viewController.modalPresentationStyle = .overFullScreen
      self?.present(viewController, animated: false, completion: nil)
      }).addDisposableTo(disposeBag)
    
    viewModel.presentOrderViewController.drive(onNext: { [weak self] in
      let storyboard = UIStoryboard(name: "Order", bundle: nil)
      let viewController = storyboard.instantiateInitialViewController()
      self?.present(viewController!, animated: true, completion: nil)
      }).addDisposableTo(disposeBag)
    
    definesPresentationContext = true
  }
  
  func configureNavigationBar() {
    // UI
    navigationController?.navigationBar.backItem?.title = ""
    navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconLocation"), style: .plain, target: self, action: nil)
    navigationItem.title = viewModel.navigationBarTitle
    
    // Bindings
    navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.locationButtonDidTap).addDisposableTo(disposeBag)
    
  }
  
  func configureSearch() {
    // UI
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.barTintColor = UIColor.chsSkyBlue
    searchController.searchBar.tintColor = UIColor.white
    searchController.searchBar.backgroundColor = UIColor.chsSkyBlue
    searchController.searchBar.backgroundImage = UIImage()
    searchController.searchBar.setSearchFieldBackgroundImage(#imageLiteral(resourceName: "searchBar"), for: .normal)
    searchController.searchBar.setImage(#imageLiteral(resourceName: "iconSearch"), for: .search, state: .normal)
    searchController.searchBar.setTextColor(color: UIColor.white)
    searchController.searchBar.searchTextPositionAdjustment = UIOffsetMake(10.0, 0.0);
    
    // Bindings
    searchController.searchBar.rx.cancelButtonClicked.bindTo(viewModel.cancelSearchButtonDidTap).addDisposableTo(disposeBag)
    searchController.searchBar.rx.text.bindTo(viewModel.searchString)
      .addDisposableTo(disposeBag)
    
  }
  
  func configureTableView() {
    // UI
    self.tableView.tableHeaderView = searchController.searchBar
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    let backView = UIView(frame: self.tableView.bounds)
    backView.backgroundColor = UIColor.chsWhite
    self.tableView.backgroundView = backView
    
    // Bindings
    dataSource.configureCell = { _, tableView, indexPath, city in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      cell.backgroundColor = UIColor.chsWhite
      cell.textLabel?.textColor = UIColor.chsSlateGrey
      cell.textLabel?.text = city.title
      cell.accessoryType = .disclosureIndicator
      
      return cell
    }
    
    tableView.delegate = nil
    tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
    
    tableView.rx.itemSelected.bindTo(viewModel.itemDidSelect).addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)
    
  }
  
  func configureFooter() {
    // Bindings
    goButton.rx.tap.bindTo(viewModel.cityNotFoundButtonDidTap).addDisposableTo(disposeBag)
  }
  
}

extension CitySelectTableViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
