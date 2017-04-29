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

typealias CategoriesSectionModel = SectionModel<String, CategoryCollectionViewCellModelType>

class CategoriesHeaderCollectionViewModel {
  let disposeBag = DisposeBag()
  let didSelectCategory = PublishSubject<Category?>()
  let categories: Variable<[Category]>

  let itemDidSelect = PublishSubject<IndexPath>()
  let sections: Driver<[CategoriesSectionModel]>

  let presentErrorAlert: PublishSubject<Error>

  init() {
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    DataManager.instance.fetchCategories().subscribe(onError: { error in
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

    self.sections = categories.asDriver().map { categories in
      var cellModels = categories.map { CategoryCollectionViewCellModelType.category($0) }
      cellModels.insert(.allCategories, at: 0)
      let section = CategoriesSectionModel(model: "", items: cellModels)
      return [section]
    }

    itemDidSelect.map {
      $0.row == 0 ? nil : categories.value[$0.row - 1]
    }.bind(to: didSelectCategory).addDisposableTo(disposeBag)

  }
}

enum CategoryCollectionViewCellModelType {
  case allCategories
  case category(Category)
}

class CategoryCollectionViewCellModel {


  var type: CategoryCollectionViewCellModelType = .allCategories

  var identity: String {
    switch type {
    case .allCategories:
      return NSLocalizedString("All", comment: "All categories")
    case .category(let category):
      return category.name
    }
  }

  init(type: CategoryCollectionViewCellModelType) {
    self.type = type
  }
}

