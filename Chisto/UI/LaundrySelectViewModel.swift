//
//  LaundrySelectViewModel.swift
//  Chisto
//
//  Created by Алексей on 27.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias LaundrySelectSectionModel = SectionModel<String, LaundrySelectTableViewCellModelType>

protocol LaundrySelectViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var sortButtonDidTap: PublishSubject<Void> { get }
  
  // Output
  var navigationBarTitle: String { get }
  var sections: Driver<[LaundrySelectSectionModel]> { get }
  var presentSortSelectSection: Driver<Void> { get }
  
  // Data
  var laundries: Variable<[Laundry]> { get }
}

class LaundrySelectViewModel: LaundrySelectViewModelType {
  let disposeBag = DisposeBag()
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var sortButtonDidTap = PublishSubject<Void>()
  
  // Output
  var navigationBarTitle = "Прачечные"
  var sections: Driver<[LaundrySelectSectionModel]>
  var presentSortSelectSection: Driver<Void>
  var presentOrderConfirmSection: Driver<OrderConfirmViewModel>
  // Data
  var laundries: Variable<[Laundry]>
  
  init() {
    DataManager.instance.fetchLaundries().subscribe().addDisposableTo(disposeBag)
    let laundries = Variable<[Laundry]>([])
    
    Observable.from(uiRealm.objects(Laundry.self))
      .map { Array($0) }
      .bindTo(laundries)
      .addDisposableTo(disposeBag)
    
    self.laundries = laundries
    
    self.sections = laundries.asDriver().map { laundries in
      let cellModels = laundries.map(LaundrySelectTableViewCellModel.init) as [LaundrySelectTableViewCellModelType]
      
      let section = LaundrySelectSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.presentSortSelectSection = sortButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    self.presentOrderConfirmSection = itemDidSelect.map { indexPath in
      let viewModel = OrderConfirmViewModel(laundry: laundries.value[indexPath.row])
      return viewModel
      }.asDriver(onErrorDriveWith: .empty())
    
  }

}
