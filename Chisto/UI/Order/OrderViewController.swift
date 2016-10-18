//
//  OrderViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderViewController: UIViewController, DefaultBarColoredViewController {

  @IBOutlet weak var emptyOrderAddButton: UIButton!
  
  @IBOutlet weak var goButton: GoButton!
  
  let footerButton = UIButton()
  
  private let viewModel = OrderViewModel()
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = viewModel.navigationBarTitle
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconUser"), style: .plain, target: nil, action: nil)
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    // Rx
    emptyOrderAddButton.rx.tap.bindTo(viewModel.emptyOrderAddButtonDidTap).addDisposableTo(disposeBag)
    navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.navigationAddButtonDidTap).addDisposableTo(disposeBag)
    
    viewModel.presentCategoriesViewController.drive(onNext: {
      let storyboard = UIStoryboard(name: "Categories", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "CategoriesViewController")
      self.navigationController?.pushViewController(viewController, animated: true)
    }).addDisposableTo(disposeBag)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
