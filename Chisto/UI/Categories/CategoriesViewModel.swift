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

typealias CategoriesSectionModel = SectionModel<String, CategoryTableViewCellModelType>

protocol CategoriesViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }

  // Output
  var sections: Driver<[CategoriesSectionModel]> { get }
  var presentItemsSection: Driver<SelectClothesViewModel> { get }
}

class CategoriesViewModel: CategoriesViewModelType {

  private let disposeBag = DisposeBag()

  // Input
  var itemDidSelect = PublishSubject<IndexPath>()

  // Output
  var sections: Driver<[CategoriesSectionModel]>
  var presentItemsSection: Driver<SelectClothesViewModel>
  var presentErrorAlert: PublishSubject<Error>

  // Data
  var categories: Variable<[Category]>

  init() {
    // Data
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    DataManager.instance.fetchCategories().subscribe(onError: { error in
      presentErrorAlert.onNext(error)
    }).addDisposableTo(disposeBag)
    
    let categories = Variable<[Category]>([])
    debugPrint(RealmManager.instance.uiRealm.objects(Category.self).sorted(byKeyPath: "name", ascending: true))

    let sortProperties = [SortDescriptor(keyPath: "featured", ascending: false), SortDescriptor(keyPath: "name", ascending: true)]

    let realm = RealmManager.instance.uiRealm

    Observable.collection(from: realm.objects(Category.self)
      .filter("isDeleted == %@", false)
      .sorted(by: sortProperties))
      .map { Array($0) }
      .bindTo(categories)
      .addDisposableTo(disposeBag)

    self.categories = categories

    self.sections = categories.asDriver().map { categories in
      let cellModels = categories.map(CategoryTableViewCellModel.init) as [CategoryTableViewCellModelType]

      let section = CategoriesSectionModel(model: "", items: cellModels)
      return [section]
    }

    self.presentItemsSection = itemDidSelect.asObservable().map { indexPath in
      let category = categories.value[indexPath.row]
      return SelectClothesViewModel(category: category)
    }.asDriver(onErrorDriveWith: .empty())
  }

}
