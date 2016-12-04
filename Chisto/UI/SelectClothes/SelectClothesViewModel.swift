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

typealias SelectClothesSectionModel = SectionModel<String, SelectClothesTableViewCellModelType>

protocol SelectClothesViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }

  // Output
  var navigationBarTitle: String { get }
  var sections: Driver<[SelectClothesSectionModel]> { get }
  var presentSelectServiceSection: Driver<ServiceSelectViewModel> { get }
}

class SelectClothesViewModel: SelectClothesViewModelType {

  private let disposeBag = DisposeBag()

  // Input
  var itemDidSelect = PublishSubject<IndexPath>()

  // Output
  var navigationBarTitle: String
  var navigationBarColor: UIColor?
  var sections: Driver<[SelectClothesSectionModel]>
  var presentSelectServiceSection: Driver<ServiceSelectViewModel>
  let presentErrorAlert: PublishSubject<Error>

  // Data
  var items: Variable<[Item]>

  init(category: Category) {
    self.navigationBarTitle = category.name
    self.navigationBarColor = category.color
    
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert
    
    DataManager.instance.fetchCategoryClothes(category: category).subscribe(onError: { error in
      presentErrorAlert.onNext(error)
    }).addDisposableTo(disposeBag)


    let items = Variable<[Item]>([])

    Observable.from(category.clothes.filter("isDeleted == %@", false))
      .map { Array($0) }
      .bindTo(items)
      .addDisposableTo(disposeBag)

    self.items = items

    self.sections = items.asDriver().map { items in
      let cellModels = items.map(SelectClothesTableViewCellModel.init) as [SelectClothesTableViewCellModelType]

      let section = SelectClothesSectionModel(model: "", items: cellModels)
      return [section]
    }

    self.presentSelectServiceSection = itemDidSelect.map { indexPath in
      let clothesItem = items.value[indexPath.row]
      let orderItem = OrderItem(clothesItem: clothesItem, treatments: [], amount: 1)
      return ServiceSelectViewModel(orderItem: orderItem)
    }.asDriver(onErrorDriveWith: .empty())

  }

}
