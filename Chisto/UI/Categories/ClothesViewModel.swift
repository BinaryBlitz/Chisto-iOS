//
//  CitySelectViewModel.swift
//  Chisto
//
//  Created by Алексей on 11.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import RealmSwift

typealias ItemsSectionModel = SectionModel<String, ItemTableViewCellModelType>

protocol ClothesViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }

  // Output
  var sections: Driver<[ItemsSectionModel]> { get }
  var presentServicesSection: Driver<ItemConfigurationViewModel> { get }
}

class ClothesViewModel: ClothesViewModelType {

  private let disposeBag = DisposeBag()

  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var searchBarString = Variable<String?>("")
  var didStartSearching = PublishSubject<Void>()
  var profileButtonDidTap = PublishSubject<Void>()
  var basketButtonDidTap = PublishSubject<Void>()
  let headerViewModel = CategoriesHeaderCollectionViewModel()

  // Output
  let sections: Driver<[ItemsSectionModel]>
  var presentProfileSection: Driver<Void>
  var presentOrderScreen: Driver<Void>
  let presentServicesSection: Driver<ItemConfigurationViewModel>
  var presentErrorAlert: PublishSubject<Error>
  var currentCategory = Variable<Category?>(nil)
  var currentItemsCount = Variable<Int>(0)
  let categoriesUpdated: PublishSubject<Void>

  // Data
  var items: Variable<[Item]>

  init() {
    // Data
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    headerViewModel.selectedCategory.asObservable().bind(to: currentCategory).addDisposableTo(disposeBag)

    let categoriesUpdated = PublishSubject<Void>()
    self.categoriesUpdated = categoriesUpdated

    OrderManager.instance.currentOrderItems.map { items in
      return items.reduce(0) { return $0 + $1.amount }
    }.bind(to: currentItemsCount).addDisposableTo(disposeBag)

    let items = Variable<[Item]>([])
    self.items = items

    let realm = try! Realm()
    let collectionObservable = Observable
      .collection(from: realm.objects(Item.self)
      .filter("isDeleted == %@", false)
      .sorted(byKeyPath: "name", ascending: true))

    let filteredItems = Observable.combineLatest(collectionObservable, searchBarString.asObservable(), currentCategory.asObservable(), headerViewModel.categories.asObservable()) { itemsCollection, searchString, category, _ -> [Item] in
      var predicates = [NSPredicate]()
      predicates.append(NSPredicate(format: "name CONTAINS[c] %@", searchString ?? ""))
      if let category = category {
        predicates.append(NSPredicate(format: "category == %@", category))
      }
      return Array(itemsCollection.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)))
    }

    filteredItems.bind(to: items).addDisposableTo(disposeBag)

    self.sections = items.asDriver().map { items in
      let cellModels = items.map(ItemTableViewCellModel.init) as [ItemTableViewCellModelType]
      let section = ItemsSectionModel(model: "", items: cellModels)

      return [section]
    }

    self.presentProfileSection = profileButtonDidTap.asDriver(onErrorDriveWith: .empty())

    self.presentOrderScreen = basketButtonDidTap.asDriver(onErrorDriveWith: .empty())

    self.presentServicesSection = itemDidSelect.asObservable()
      .map { indexPath in
        let item = items.value[indexPath.row]
        return ItemConfigurationViewModel(orderItem: OrderItem(clothesItem: item))
      }
      .asDriver(onErrorDriveWith: .empty())
    
    didStartSearching.asObservable().take(1).flatMap {
      DataManager.instance.fetchClothesIfNeeded().do(onError: { error in
        presentErrorAlert.onNext(error)
      })
    }.subscribe().addDisposableTo(disposeBag)

    fetchItemsIfNeeded(true)
  }

  func fetchItemsIfNeeded(_ force: Bool = false) {
    let fetchCategoriesObservable = DataManager.instance.fetchCategoriesIfNeeded(force).do(onError: { [weak self] error in
      self?.presentErrorAlert.onNext(error)
    })

    let fetchItemsObservable = DataManager.instance.fetchClothesIfNeeded(force).do(onError: { [weak self] error in
      self?.presentErrorAlert.onNext(error)
    })

    Observable.combineLatest(fetchCategoriesObservable, fetchItemsObservable).subscribe(onNext: { [weak self] _, _ in
      self?.categoriesUpdated.onNext()

    }).addDisposableTo(disposeBag)

  }

}
