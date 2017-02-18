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
  let itemDidSelect = PublishSubject<IndexPath>()
  let decorationViewDidClose = PublishSubject<Void>()

  // Output
  var navigationBarTitle: String
  var navigationBarColor: UIColor?
  var sections: Driver<[SelectClothesSectionModel]>
  var presentSelectServiceSection: Driver<ServiceSelectViewModel>
  var presentHasDecorationAlert: Driver<HasDecorationAlertViewModel>
  let decorationAlertDidFinish: PublishSubject<OrderItem>
  let presentErrorAlert: PublishSubject<Error>

  // Data
  var items: Variable<[Item]>

  init(category: Category) {
    self.navigationBarTitle = category.name
    self.navigationBarColor = category.color

    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    let decorationAlertDidFinish = PublishSubject<OrderItem>()
    self.decorationAlertDidFinish = decorationAlertDidFinish


    DataManager.instance.fetchCategoryClothes(category: category).subscribe(onError: { error in
        presentErrorAlert.onNext(error)
      }).addDisposableTo(disposeBag)


    let items = Variable<[Item]>([])

    Observable.collection(from: category.clothes.filter("isDeleted == %@", false)
        .sorted(byKeyPath: "name", ascending: true))
      .map { Array($0) }
      .bindTo(items)
      .addDisposableTo(disposeBag)

    self.items = items

    self.sections = items.asDriver().map { items in
      let cellModels = items.map(SelectClothesTableViewCellModel.init) as [SelectClothesTableViewCellModelType]

      let section = SelectClothesSectionModel(model: "", items: cellModels)
      return [section]
    }

    let selectedItemObservable = itemDidSelect.map { items.value[$0.row] }

    self.presentHasDecorationAlert = selectedItemObservable.filter { $0.hasDecoration }.map { item in
      let orderItem = OrderItem(clothesItem: item)
      let viewModel = HasDecorationAlertViewModel(orderItem: orderItem)
      viewModel.didFinishAlert.bindTo(decorationAlertDidFinish).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    let noDecorationItemSelectedDriver = selectedItemObservable.filter { !$0.hasDecoration }
      .map { OrderItem(clothesItem: $0) }
      .asDriver(onErrorDriveWith: .empty())

    self.presentSelectServiceSection = Driver.of(decorationAlertDidFinish.asDriver(onErrorDriveWith: .empty()), noDecorationItemSelectedDriver).merge().map { orderItem in
      return ServiceSelectViewModel(orderItem: orderItem, hasDecoration: orderItem.hasDecoration)
    }

  }

}
