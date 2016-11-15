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
  var presentSortSelectSection: Driver<LaundrySortViewModel> { get }

  // Data
  var sortedLaundries: Variable<[Laundry]> { get }
}

class LaundrySelectViewModel: LaundrySelectViewModelType {

  let disposeBag = DisposeBag()

  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var sortButtonDidTap = PublishSubject<Void>()

  // Output
  var navigationBarTitle = "Химчистки"
  var sections: Driver<[LaundrySelectSectionModel]>
  var presentOrderConfirmSection: Driver<OrderConfirmViewModel>
  var presentSortSelectSection: Driver<LaundrySortViewModel>

  // Data
  var sortedLaundries: Variable<[Laundry]>
  var sortType: Variable<LaundrySortType>

  init() {
    DataManager.instance.fetchLaundries().subscribe().addDisposableTo(disposeBag)
    let laundries = Variable<[Laundry]>([])

    Observable.from(uiRealm.objects(Laundry.self))
      .map { Array($0) }
      .bindTo(laundries)
      .addDisposableTo(disposeBag)

    let sortType = Variable<LaundrySortType>(LaundrySortType.byRating)
    self.sortType = sortType

    let sortedLaundries = Variable(laundries.value)
    self.sortedLaundries = sortedLaundries

    self.sections = sortedLaundries.asDriver().map { laundries in
      let cellModels = laundries.map(LaundrySelectTableViewCellModel.init) as [LaundrySelectTableViewCellModelType]

      let section = LaundrySelectSectionModel(model: "", items: cellModels)
      return [section]
    }

    self.presentSortSelectSection = sortButtonDidTap.asObservable().map {
      let viewModel = LaundrySortViewModel()
      viewModel.selectedSortType.bindTo(sortType).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    self.presentOrderConfirmSection = itemDidSelect.map { indexPath in
      let viewModel = OrderConfirmViewModel(laundry: laundries.value[indexPath.row])
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    Observable.combineLatest(laundries.asObservable(), sortType.asObservable()) { laundries, sortType -> [Laundry] in
      return self.sortLaundries(laundries: laundries, sortType: sortType)
    }.bindTo(sortedLaundries).addDisposableTo(disposeBag)


  }

  func sortLaundries(laundries: [Laundry], sortType: LaundrySortType) -> [Laundry] {
    let orderManager = OrderManager.instance
    switch sortType {
    case .byPrice:
      return laundries.sorted { orderManager.price(laundry: $0) < orderManager.price(laundry: $1) }
    case .byRating:
      return laundries.sorted { $0.rating > $1.rating }
    case .bySpeed:
      return laundries.sorted { $0.deliveryDate < $1.deliveryDate }
    }
  }

}
