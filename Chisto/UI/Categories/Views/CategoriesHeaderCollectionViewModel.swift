//
//  CategoriesHeaderCollectionViewModel.swift
//  Chisto
//
//  Created by Алексей on 28.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm
import Realm
import RealmSwift
import RxDataSources

typealias CategoriesSectionModel = SectionModel<String, CategoryCollectionViewCellModel>

class CategoriesHeaderCollectionViewModel {
  let disposeBag = DisposeBag()
  let selectedCategory = Variable<Category?>(nil)
  let selectCell = PublishSubject<Int>()
  let categories: Variable<[Category]>

  let itemDidSelect = PublishSubject<IndexPath>()
  let sections: Driver<[CategoriesSectionModel]>

  let presentErrorAlert: PublishSubject<Error>

  init() {
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    DataManager.instance.fetchCategoriesIfNeeded(true).subscribe(onError: { error in
      presentErrorAlert.onNext(error)
    }).addDisposableTo(disposeBag)

    let categories = Variable<[Category]>([])

    let sortProperties = [
      SortDescriptor(keyPath: "featured", ascending: false),
      SortDescriptor(keyPath: "name", ascending: true)
    ]

    let realm = RealmManager.instance.uiRealm

    Observable
      .collection(from: realm.objects(Category.self).filter("isDeleted == %@", false).sorted(by: sortProperties))
      .map { Array($0) }
      .bind(to: categories)
      .addDisposableTo(disposeBag)

    self.categories = categories

    self.sections = Driver.combineLatest(categories.asDriver(), selectedCategory.asDriver()) { categories, selectedCategory in
      var cellModels = categories.map { CategoryCollectionViewCellModel.init(type: .category($0), isSelected: selectedCategory?.id == $0.id) }
      cellModels.insert(CategoryCollectionViewCellModel.init(type: .allCategories, isSelected: selectedCategory == nil), at: 0)
      let section = CategoriesSectionModel(model: "", items: cellModels)
      return [section]
    }

    itemDidSelect.map {
      $0.row == 0 ? nil : categories.value[$0.row - 1]
    }.bind(to: selectedCategory).addDisposableTo(disposeBag)

    selectedCategory
      .asObservable()
      .distinctUntilChanged { $0?.id != $1?.id }
      .map { category in
        guard let category = category,
          let index = categories.value.index(of: category) else { return 0 }
        return index
      }
      .bind(to: selectCell)
      .addDisposableTo(disposeBag)

  }
}

enum CategoryCollectionViewCellModelType {
  case allCategories
  case category(Category)
}

class CategoryCollectionViewCellModel {

  var type: CategoryCollectionViewCellModelType = .allCategories
  var isSelected: Bool

  var identity: String {
    switch type {
    case .allCategories:
      return NSLocalizedString("All", comment: "All categories")
    case .category(let category):
      return category.name
    }
  }

  init(type: CategoryCollectionViewCellModelType, isSelected: Bool = false) {
    self.type = type
    self.isSelected = isSelected
  }
}

