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
    let viewModel = CitySelectViewModel()
    let disposeBag = DisposeBag()
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor.chsSkyBlue
        navigationController?.navigationBar.backItem?.title = ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconLocation"), style: .plain, target: self, action: nil)
        
        navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.locationButtonDidTap).addDisposableTo(disposeBag)
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
        
        
        searchController.searchBar.barTintColor = UIColor.chsSkyBlue
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.backgroundColor = UIColor.chsSkyBlue
        
        searchController.searchBar.rx.cancelButtonClicked.bindTo(viewModel.cancelSearchButtonDidTap).addDisposableTo(disposeBag)
        
        searchController.searchBar.backgroundImage = UIImage()
        searchController.dimsBackgroundDuringPresentation = true
        
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
        
        self.tableView.tableHeaderView = searchController.searchBar
        
        view.addSubview(tableView)
        tableView <- [
            Top(),
            Left(),
            Right(),
        ]
        
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
            Height(53)
         ]
        
        definesPresentationContext = true

        searchController.searchBar.rx.text.bindTo(viewModel.searchString)
            .addDisposableTo(disposeBag)
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dataSource.configureCell = { _, tableView, indexPath, city in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = UIColor.chsWhite
            cell.textLabel?.text = city.title
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        tableView.delegate = nil
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        tableView.dataSource = nil
        viewModel.sections
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .addDisposableTo(self.disposeBag)
    }

}

extension CitySelectTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
