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

  // Data
  var items: Variable<[Item]>

  init() {
    // Data
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    headerViewModel.selectedCategory.asObservable().bind(to: currentCategory).addDisposableTo(disposeBag)

    _ = DataManager.instance.fetchClothes().subscribe(onError: { error in
      presentErrorAlert.onNext(error)
    })

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

    let filteredItems = Observable.combineLatest(collectionObservable, searchBarString.asObservable(), currentCategory.asObservable()) { itemsCollection, searchString, category -> [Item] in
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
      DataManager.instance.fetchClothes().do(onError: { error in
        presentErrorAlert.onNext(error)
      })
    }.subscribe().addDisposableTo(disposeBag)
  }

}
