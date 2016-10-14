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
import EasyPeasy

class CitySelectTableViewController: UIViewController, UIScrollViewDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var dataSource = RxTableViewSectionedReloadDataSource<CitySelectSectionModel>()
    private let viewModel = CitySelectViewModel()
    private let disposeBag = DisposeBag()
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        configureSearch()
        configureFooter()
        
        viewModel.presentCityNotFoundController.drive(onNext: { [weak self] in
            let viewController = CityNotFoundViewController()
            viewController.modalPresentationStyle = .overFullScreen
            self?.present(viewController, animated: false, completion: nil)
        }).addDisposableTo(disposeBag)
        
        viewModel.presentOrderViewController.drive(onNext: { [weak self] in
            self?.navigationController?.pushViewController(OrderViewController(), animated: true)
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
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.barTintColor = UIColor.chsSkyBlue
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.backgroundColor = UIColor.chsSkyBlue
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.setSearchFieldBackgroundImage(#imageLiteral(resourceName: "searchBar"), for: .normal)
        
        // Bindings
        searchController.searchBar.rx.cancelButtonClicked.bindTo(viewModel.cancelSearchButtonDidTap).addDisposableTo(disposeBag)
        searchController.searchBar.rx.text.bindTo(viewModel.searchString)
            .addDisposableTo(disposeBag)

    }
    
    func configureTableView() {
        // UI
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
        self.tableView.tableHeaderView = searchController.searchBar
        
        view.addSubview(tableView)
        tableView <- [
            Top(),
            Left(),
            Right(),
        ]
        
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
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
        // UI
        let goButton = UIButton()
        goButton.backgroundColor = UIColor.chsSkyBlue
        goButton.titleLabel?.textColor = UIColor.white
        goButton.setTitle("Не нашли свой город?", for: .normal)
        
        view.addSubview(goButton)
        
        goButton <- [
            Left(),
            Top().to(tableView),
            Bottom().to(view, .bottom),
            Right(),
            Height(50)
        ]
        
        // Bindings
        goButton.rx.tap.bindTo(viewModel.cityNotFoundButtonDidTap).addDisposableTo(disposeBag)
    }

}

extension CitySelectTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
