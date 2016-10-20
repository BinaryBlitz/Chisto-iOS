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

class CitySelectTableViewController: UIViewController, UIScrollViewDelegate {
  
  @IBOutlet weak var searchBar: UISearchBar!
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
      let viewController = CityNotFoundViewController.storyboardInstance()!
      viewController.modalPresentationStyle = .overFullScreen
      self?.present(viewController, animated: false, completion: nil)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentOrderViewController.drive(onNext: { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    viewModel.showCancelButtonAnimated.drive(onNext: { [weak self] in
      self?.searchBar.setShowsCancelButton(true, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.hideCancelButtonAnimated.drive(onNext: { [weak self] in
      self?.searchBar.setShowsCancelButton(false, animated: true)
    }).addDisposableTo(disposeBag)
    
    viewModel.hideKeyboard.drive(onNext: { [weak self] in
      self?.view.endEditing(true)
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
    searchBar.barTintColor = UIColor.chsSkyBlue
    searchBar.tintColor = UIColor.white
    searchBar.backgroundColor = UIColor.chsSkyBlue
    searchBar.backgroundImage = UIImage()
    searchBar.setSearchFieldBackgroundImage(#imageLiteral(resourceName: "searchBarTextBack"), for: .normal)
    searchBar.setImage(#imageLiteral(resourceName: "iconSearch"), for: .search, state: .normal)
    searchBar.setTextColor(color: UIColor.white)
    searchBar.searchTextPositionAdjustment = UIOffsetMake(5.0, 0.0)

    // Bindings
    searchBar.rx.cancelButtonClicked.bindTo(viewModel.cancelSearchButtonDidTap).addDisposableTo(disposeBag)
    searchBar.rx.textDidBeginEditing.bindTo(viewModel.searchBarDidBeginEditing).addDisposableTo(disposeBag)
    searchBar.rx.textDidEndEditing.bindTo(viewModel.searchBarDidEndEditing).addDisposableTo(disposeBag)
    searchBar.rx.text.bindTo(viewModel.searchString)
      .addDisposableTo(disposeBag)
    
  }
  
  func configureTableView() {
    // UI    
    let backView = UIView(frame: tableView.bounds)
    backView.backgroundColor = UIColor.chsWhite
    tableView.backgroundView = backView
    
    // Bindings
    dataSource.configureCell = { _, tableView, indexPath, city in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CitySelectTableViewCell", for: indexPath)
      cell.textLabel?.text = city.title      
      return cell
    }
    
    tableView.delegate = nil
    tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
    
    tableView.rx.itemSelected.bindTo(viewModel.itemDidSelect).addDisposableTo(disposeBag)
    
    tableView.dataSource = nil
    viewModel.sections
      .drive(tableView.rx.items(dataSource: dataSource))
      .addDisposableTo(disposeBag)
    
  }
  
  func configureFooter() {
    // Bindings
    goButton.rx.tap.bindTo(viewModel.cityNotFoundButtonDidTap).addDisposableTo(disposeBag)
  }
  
}
