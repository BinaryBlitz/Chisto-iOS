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

class ClothesViewModel {


  private let disposeBag = DisposeBag()
  // Input
  let itemDidSelect = PublishSubject<IndexPath>()
  let searchBarString = Variable<String?>("")
  let didStartSearching = PublishSubject<Void>()
  let didFinishSearching = PublishSubject<Void>()
  let profileButtonDidTap = PublishSubject<Void>()
  let basketButtonDidTap = PublishSubject<Void>()
  let presentRatingAlert: Driver<OrderReviewAlertViewModel>
  let headerViewModel = CategoriesHeaderCollectionViewModel()

  // Output
  let sections: Driver<[ItemsSectionModel]>
  var presentProfileSection: Driver<Void>
  var presentOrderScreen: Driver<Void>
  var presentRatingSection: Driver<OrderReviewAlertViewModel>
  let presentServicesSection: Driver<ItemConfigurationViewModel>
  var presentErrorAlert: PublishSubject<Error>
  var currentCategory = Variable<Category?>(nil)
  var currentItemsCount = Variable<Int>(0)
  var basketButtonEnabled = Variable<Bool>(true)
  let categoriesUpdated: PublishSubject<Void>

  // Data
  var items: Variable<[Item]>
  var previousCategory: Category? = nil

  init() {
    // Data
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert


    let fetchLastOrder = DataManager.instance.showUser().map { ProfileManager.instance.userProfile.value.order }

    self.presentRatingSection = fetchLastOrder
      .filter { order in
        guard let order = order else { return false }
        return order.status == .completed && order.rating == nil && order.ratingRequired
      }.map { order in
        return OrderReviewAlertViewModel(order: order!)
      }.asDriver(onErrorDriveWith: .empty())

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

    let basketButtonDidTap = self.basketButtonDidTap
    self.presentOrderScreen = basketButtonDidTap.asDriver(onErrorDriveWith: .empty())

    self.presentServicesSection = itemDidSelect.asObservable()
      .map { indexPath in
        let item = items.value[indexPath.row]
        return ItemConfigurationViewModel(orderItem: OrderItem(clothesItem: item))
      }
      .asDriver(onErrorDriveWith: .empty())
    

    let shouldRateOrderObservable = DataManager.instance.showUser()
      .map { ProfileManager.instance.userProfile.value.order }.filter { order in
        guard let order = order else { return false }
        return order.paid && order.paymentMethod != .cash
    }

    presentRatingAlert = shouldRateOrderObservable
      .asDriver(onErrorDriveWith: .empty())
      .map { OrderReviewAlertViewModel(order: $0!) }

    _ = basketButtonDidTap.asDriver(onErrorDriveWith: .empty()).flatMap { [weak self] _ -> Driver<Void> in
      return DataManager.instance.showUser()
        .asDriver(onErrorDriveWith: .just()).do(onCompleted: { [weak self] in
          self?.basketButtonEnabled.value = true
          }, onSubscribe: { [weak self] in
            self?.basketButtonEnabled.value = false
        })
    }



    didStartSearching.asObservable()
      .withLatestFrom(currentCategory.asObservable())
      .subscribe(onNext: { [weak self] category in
        self?.previousCategory = category
        self?.currentCategory.value = nil
    }).addDisposableTo(disposeBag)

    didStartSearching.asObservable().take(1).flatMap {
      DataManager.instance.fetchClothesIfNeeded().do(onError: { error in
        presentErrorAlert.onNext(error)
      })
    }.subscribe().addDisposableTo(disposeBag)

    didFinishSearching.asObservable()
      .map { self.previousCategory }
      .bind(to: currentCategory)
      .addDisposableTo(disposeBag)

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
