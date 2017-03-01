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

typealias SelectClothesSectionModel = SectionModel<String, SelectClothesTableViewCellModelType>

protocol SelectClothesViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }

  // Output
  var navigationBarTitle: String? { get }
  var sections: Driver<[SelectClothesSectionModel]> { get }
  var presentSelectServiceSection: Driver<ServiceSelectViewModel> { get }
}

class SelectClothesViewModel: SelectClothesViewModelType {

  private let disposeBag = DisposeBag()

  // Input
  let itemDidSelect = PublishSubject<IndexPath>()
  let decorationViewDidClose = PublishSubject<Void>()

  // Output
  var navigationBarTitle: String? = nil
  var navigationBarColor: UIColor?
  var sections: Driver<[SelectClothesSectionModel]>
  var presentSelectServiceSection: Driver<ServiceSelectViewModel>
  var presentHasDecorationAlert: Driver<HasDecorationAlertViewModel>
  var presentSlowItemAlert: PublishSubject<Void>
  let decorationAlertDidFinish: PublishSubject<OrderItem>
  let presentErrorAlert: PublishSubject<Error>

  // Data
  var items: Variable<[Item]>

  init(category: Category?, searchString: Variable<String?> = Variable("")) {
    self.navigationBarTitle = category?.name
    self.navigationBarColor = category?.color

    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    let decorationAlertDidFinish = PublishSubject<OrderItem>()
    self.decorationAlertDidFinish = decorationAlertDidFinish


    var presentSlowItemAlert = PublishSubject<Void>()
    self.presentSlowItemAlert = presentSlowItemAlert

    let items = Variable<[Item]>([])
    self.items = items

    let realm = try! Realm()
    let collectionObservable = Observable.collection(from: realm.objects(Item.self)
      .filter("isDeleted == %@", false)
      .sorted(byKeyPath: "name", ascending: true))

    let category = category
    
    let filteredItems = Observable.combineLatest(collectionObservable, searchString.asObservable()) { itemsCollection, searchString -> [Item] in
      var predicates = [NSPredicate]()
      predicates.append(NSPredicate(format: "name CONTAINS[c] %@", searchString ?? ""))
      if let category = category {
        predicates.append(NSPredicate(format: "category == %@", category))
      }
      return Array(itemsCollection.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)))
    }

    filteredItems.bindTo(items).addDisposableTo(disposeBag)

    if let category = category {
      DataManager.instance.fetchCategoryClothes(category: category).subscribe(onError: { error in
        presentErrorAlert.onNext(error)
      }).addDisposableTo(disposeBag)
    }

    self.sections = items.asDriver().map { items in
      let cellModels = items.map(SelectClothesTableViewCellModel.init) as [SelectClothesTableViewCellModelType]

      cellModels.forEach { $0.slowItemButtonDidTap.bindTo(presentSlowItemAlert).addDisposableTo($0.disposeBag) }

      let section = SelectClothesSectionModel(model: "", items: cellModels)
      return [section]
    }

    let selectedItemObservable = itemDidSelect.map { items.value[$0.row] }

    self.presentHasDecorationAlert = selectedItemObservable.filter { $0.hasDecoration && !ProfileManager.instance.userProfile.value.disabledDecorationAlert }.map { item in
      let orderItem = OrderItem(clothesItem: item)
      let viewModel = HasDecorationAlertViewModel(orderItem: orderItem)
      viewModel.didFinishAlert.bindTo(decorationAlertDidFinish).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    let noDecorationItemSelectedDriver = selectedItemObservable.filter { !$0.hasDecoration || ProfileManager.instance.userProfile.value.disabledDecorationAlert }
      .map { OrderItem(clothesItem: $0) }
      .asDriver(onErrorDriveWith: .empty())

    self.presentSelectServiceSection = Driver.of(decorationAlertDidFinish.asDriver(onErrorDriveWith: .empty()), noDecorationItemSelectedDriver).merge().map { orderItem in
      return ServiceSelectViewModel(orderItem: orderItem, hasDecoration: orderItem.hasDecoration)
    }

  }

}
