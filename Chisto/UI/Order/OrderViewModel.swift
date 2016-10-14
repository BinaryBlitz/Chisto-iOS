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
}


class OrderViewModel: OrderViewModelType {
  // Input
  var navigationAddButtonDidTap = PublishSubject<Void>()
  var emptyOrderAddButtonDidTap = PublishSubject<Void>()
  
  var presentCategoriesViewController: Driver<Void>
  
  init() {
    self.presentCategoriesViewController = Observable.of(navigationAddButtonDidTap.asObservable(), emptyOrderAddButtonDidTap.asObservable()).merge().asDriver(onErrorJustReturn: ())
  }
}
