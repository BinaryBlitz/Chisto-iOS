//
//  ProfileViewController.swift
//  Chisto
//
//  Created by Алексей on 28.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UITableViewController {
  let viewModel = ProfileViewModel()
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavbarClose"), style: .plain, target: nil, action: nil)
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    navigationItem.leftBarButtonItem?.rx.tap.bindTo(viewModel.closeButtonDidTap)
      .addDisposableTo(disposeBag)
    
    tableView.rx.itemSelected.bindTo(viewModel.itemDidSelect)
      .addDisposableTo(disposeBag)
    
    viewModel.dismissViewController.drive(onNext: { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    viewModel.presentAboutSection.drive(onNext: { [weak self] in
      let viewController = AboutViewController.storyboardInstance()!
      self?.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)

  }
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    view.tintColor = UIColor.chsWhiteTwo
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  
}
