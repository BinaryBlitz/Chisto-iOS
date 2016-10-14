//
//  OrderViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy
import RxSwift
import RxCocoa

class OrderViewController: UIViewController {
    // Constants
    let footerButtonTitle = "Ничего не выбрано"
    
    let tableView = UITableView()
    let emptyOrderView = EmptyOrderView()
    let footerButton = UIButton()
    
    private let viewModel = OrderViewModel()
    private let disposeBag = DisposeBag()
    
    var emptyOrderViewAddButtonDidTap: ControlEvent<Void> {
        return emptyOrderView.addButtonDidTap
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconUser"), style: .plain, target: nil, action: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        view.addSubview(emptyOrderView)
        emptyOrderView <- [
            Top(),
            Left(),
            Right()
        ]
        
        footerButton.backgroundColor = UIColor.chsCoolGrey
        footerButton.isEnabled = false
        footerButton.setTitle(footerButtonTitle, for: .normal)
        footerButton.titleLabel?.alpha = 0.5
        view.addSubview(footerButton)
        
        footerButton <- [
            Bottom(),
            Left(),
            Right(),
            Top().to(emptyOrderView),
            Height(50)
        ]
        
        // Rx
        emptyOrderViewAddButtonDidTap.bindTo(viewModel.emptyOrderAddButtonDidTap).addDisposableTo(disposeBag)
        navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.navigationAddButtonDidTap).addDisposableTo(disposeBag)
        
        viewModel.presentCategoriesViewController.drive(onNext: {
            self.navigationController?.pushViewController(CategoriesViewController(), animated: true)
            }).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
