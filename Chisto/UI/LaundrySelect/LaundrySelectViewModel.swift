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
  var sections: Driver<[LaundrySelectSectionModel]> { get }
  var presentSortSelectSection: Driver<Void> { get }

  // Data
  var sortedLaundries: Variable<[Laundry]> { get }
}

enum LaundrySortType {
  case byPrice
  case bySpeed
  case byRating
}

class LaundrySelectViewModel: LaundrySelectViewModelType {

  let disposeBag = DisposeBag()

  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var sortButtonDidTap = PublishSubject<Void>()

  // Output
  var sections: Driver<[LaundrySelectSectionModel]>
  var presentOrderConfirmSection: Driver<OrderConfirmViewModel>
  var presentSortSelectSection: Driver<Void>
  var presentErrorAlert: PublishSubject<Error>

  // Data
  var sortedLaundries: Variable<[Laundry]>
  var sortType: Variable<LaundrySortType>

  init() {
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    DataManager.instance.fetchLaundries().subscribe(onError: { error in
      presentErrorAlert.onNext(error)
    }).addDisposableTo(disposeBag)

    let laundries = Variable<[Laundry]>([])

    let sortType = Variable<LaundrySortType>(LaundrySortType.byRating)
    self.sortType = sortType

    let sortedLaundries = Variable<[Laundry]>([])
    self.sortedLaundries = sortedLaundries

    self.sections = sortedLaundries.asDriver().map { laundries in
      let orderManager = OrderManager.instance

      let cheapestLaundry = laundries.sorted { orderManager.price(laundry: $0) > orderManager.price(laundry: $1) }.first
      let fastestLaundry = laundries.filter { $0 != cheapestLaundry }.sorted { $0.collectionDate > $1.collectionDate }.first

      let cellModels = laundries.map { laundry in
        var type: LaundryType? = nil
        if laundry == fastestLaundry { type = .fast }
        if laundry == cheapestLaundry { type = .cheap }
        return LaundrySelectTableViewCellModel(laundry: laundry, type: type)
      } as [LaundrySelectTableViewCellModelType]

      let section = LaundrySelectSectionModel(model: "", items: cellModels)
      return [section]
    }

    self.presentSortSelectSection = sortButtonDidTap.asDriver(onErrorDriveWith: .empty())

    self.presentOrderConfirmSection = itemDidSelect.map { indexPath in
      let viewModel = OrderConfirmViewModel(laundry: sortedLaundries.value[indexPath.row])
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())
    
    let currentOrderItemsObservable = OrderManager.instance.currentOrderItems.asObservable()

    let filteredLaundriesObservable = Observable
      .combineLatest(laundries.asObservable(), currentOrderItemsObservable) { [weak self] laundries, currentOrderItems -> [Laundry] in
        self?.filterLaundries(laundries: laundries, currentOrderItems: currentOrderItems) ?? []
      }

    Observable.combineLatest(filteredLaundriesObservable.asObservable(), sortType.asObservable()) { laundries, sortType -> [Laundry] in
      return self.sortLaundries(laundries: laundries, sortType: sortType)
    }.bindTo(sortedLaundries).addDisposableTo(disposeBag)

    guard let profileCity = ProfileManager.instance.userProfile.value.city else { return }

    let laundryObjects = uiRealm.objects(Laundry.self)
      .filter("isDeleted == %@ AND city == %@", false, profileCity)

    Observable.from(laundryObjects.sorted(byProperty: "rating"))
      .map { Array($0) }
      .bindTo(laundries)
      .addDisposableTo(disposeBag)
  }

  func filterLaundries(laundries: [Laundry], currentOrderItems: [OrderItem]) -> [Laundry] {
    return laundries.filter { laundry in
      let laundryTreatments = Set(laundry.treatments)
      let orderTreatments = Set(currentOrderItems.map { $0.treatments }.reduce([], +))
      return orderTreatments.subtracting(laundryTreatments).isEmpty
    }
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
