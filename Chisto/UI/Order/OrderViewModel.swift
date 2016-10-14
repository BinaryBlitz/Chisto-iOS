//
//  OrderViewModel.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

protocol OrderViewModelType {
  // Input
  var navigationAddButtonDidTap: PublishSubject<Void> { get }
  var emptyOrderAddButtonDidTap: PublishSubject<Void> { get }
  
  // Output
  var presentCategoriesViewController: Driver<Void> { get }
  var navigationBarTitle: String { get }
  var footerButtonTitle: String { get }
}


class OrderViewModel: OrderViewModelType {
  // Input
  var navigationAddButtonDidTap = PublishSubject<Void>()
  var emptyOrderAddButtonDidTap = PublishSubject<Void>()
  
  // Output
  var presentCategoriesViewController: Driver<Void>
  
  // Constants
  let navigationBarTitle = "Заказ"
  let footerButtonTitle = "Ничего не выбрано"
  
  init() {
    self.presentCategoriesViewController = Observable.of(navigationAddButtonDidTap.asObservable(), emptyOrderAddButtonDidTap.asObservable()).merge().asDriver(onErrorJustReturn: ())
  }
}
