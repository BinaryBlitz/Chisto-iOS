//
//  ServiceSelectViewModel.swift
//  Chisto
//
//  Created by Алексей on 19.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

typealias ServiceSelectSectionModel = SectionModel<String, ServiceSelectTableViewCellModelType>

protocol ServiceSelectViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var itemDidDeselect: PublishSubject<IndexPath> { get }
  var readyButtonTapped: PublishSubject<Void> { get }

  // Output
  var itemTitle: String { get }
  var color: UIColor { get }
  var sections: Driver<[ServiceSelectSectionModel]> { get }
  var selectedServicesIds: Variable<[Int]> { get }
  var selectedServices: PublishSubject<[Treatment]> { get }
}

class ServiceSelectViewModel: ServiceSelectViewModelType {

  let disposeBag = DisposeBag()

  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var itemDidDeselect = PublishSubject<IndexPath>()
  var readyButtonTapped = PublishSubject<Void>()

  // Output
  var color: UIColor
  var navigationItemTitle = "Выбор услуг"
  var itemTitle: String
  var sections: Driver<[ServiceSelectSectionModel]>
  var showNewSection: PublishSubject<NewSection>

  // Data
  var saveNeeded: Bool
  var orderItem: OrderItem
  enum NewSection {
    case orderItem
    case order
    case areaAlert(viewModel: ItemSizeAlertViewModel)
  }

  enum Section: Int {
    case decoration = 0
    case treatments
  }

  var selectedServicesIds: Variable<[Int]>
  var treatments: Variable<[Treatment]>
  var selectedServices: PublishSubject<[Treatment]>
  var hasDecoration = PublishSubject<Bool>()
  let decorationCellModel: Variable<ServiceSelectTableViewCellModel>
  let needPresentAreaAlert: Bool

  init(orderItem: OrderItem, saveNeeded: Bool = true,
       selectedTreatments: [Treatment] = [],
       hasDecoration: Bool = false) {

    self.saveNeeded = saveNeeded
    self.orderItem = orderItem
    self.needPresentAreaAlert = orderItem.clothesItem.useArea

    let item = orderItem.clothesItem

    let decorationCellModel = Variable(
      ServiceSelectTableViewCellModel(
        "Декор", "Декоративная отделка", item.category?.color, isSelected: hasDecoration
      )
    )
    self.decorationCellModel = decorationCellModel

    DataManager.instance.fetchClothesTreatments(item: item).subscribe().addDisposableTo(disposeBag)
    let treatments = Variable<[Treatment]>([])
    Observable.from(item.treatments.filter("isDeleted == %@", false).sorted(byKeyPath: "name"))
      .map { Array($0) }
      .bindTo(treatments)
      .addDisposableTo(disposeBag)
    self.treatments = treatments

    self.itemTitle = item.name
    self.color = item.category?.color ?? UIColor.chsSkyBlue

    let selectedServicesIds = Variable<[Int]>(selectedTreatments.map { $0.id })
    self.selectedServicesIds = selectedServicesIds

    let selectedServices = PublishSubject<[Treatment]>()
    self.selectedServices = selectedServices

    self.sections = Driver.combineLatest(treatments.asDriver(), selectedServicesIds.asDriver(), decorationCellModel.asDriver()) { services, selectedServicesIds, decorationCellModel in
      let cellModels = services.map { service in
        ServiceSelectTableViewCellModel(
          treatment: service,
          isSelected: selectedServicesIds.index(of: service.id) != nil
        )
      } as [ServiceSelectTableViewCellModelType]

      let decorationSection = ServiceSelectSectionModel(model: "", items: [decorationCellModel]
        as [ServiceSelectTableViewCellModelType])

      let servicesSection = ServiceSelectSectionModel(model: "", items: cellModels)

      return [decorationSection, servicesSection]
    }

    let showNewSection = PublishSubject<NewSection>()
    self.showNewSection = showNewSection

    let returnSection: NewSection = saveNeeded ? .order : .orderItem

    readyButtonTapped.asObservable().map { [weak self] in
      guard let needPresentAreaAlert = self?.needPresentAreaAlert else { return returnSection }
      guard needPresentAreaAlert else { return returnSection }
      let viewModel = ItemSizeAlertViewModel(orderItem: orderItem)
      viewModel.didFinishAlertSuccess.asObservable().map { returnSection }
        .bindTo(showNewSection).addDisposableTo(viewModel.disposeBag)
      return .areaAlert(viewModel: viewModel)
    }.bindTo(showNewSection).addDisposableTo(disposeBag)

    readyButtonTapped.asObservable()
      .map {
        treatments.value.filter { selectedServicesIds.value.contains($0.id) }
      }
      .bindTo(selectedServices)
      .addDisposableTo(disposeBag)

    readyButtonTapped.asObservable()
      .map {
        decorationCellModel.value.isSelected
      }
      .bindTo(self.hasDecoration)
      .addDisposableTo(disposeBag)

    self.hasDecoration.asObservable()
      .subscribe(onNext: saveDecorationIfNeeded)
      .addDisposableTo(disposeBag)

    selectedServices.asObservable()
      .subscribe(onNext: saveTreatmentsIfNeeded)
      .addDisposableTo(disposeBag)

    self.itemDidSelect.asObservable()
      .subscribe(onNext: itemDidSelect)
      .addDisposableTo(disposeBag)

    self.itemDidDeselect.asObservable()
      .subscribe(onNext: itemDidDeselect)
      .addDisposableTo(disposeBag)
  }

  func saveDecorationIfNeeded(_ hasDecoration: Bool) {
    if saveNeeded {
      OrderManager.instance.updateOrderItem(orderItem) {
        orderItem.hasDecoration = hasDecoration
      }
    }
  }

  func saveTreatmentsIfNeeded(_ treatments: [Treatment]) {
    if saveNeeded {
      OrderManager.instance.updateOrderItem(orderItem) {
        orderItem.treatments = treatments
      }
    }
  }

  func itemDidSelect(_ indexPath: IndexPath) {
    switch indexPath.section {
    case Section.decoration.rawValue:
      let viewModel = decorationCellModel.value
      viewModel.isSelected = true
      decorationCellModel.value = viewModel
    case Section.treatments.rawValue:
      let service = self.treatments.value[indexPath.row]
      self.selectedServicesIds.value.append(service.id)
    default:
      break
    }
  }

  func itemDidDeselect(_ indexPath: IndexPath) {
    switch indexPath.section {
    case Section.decoration.rawValue:
      let viewModel = decorationCellModel.value
      viewModel.isSelected = false
      decorationCellModel.value = viewModel
    case Section.treatments.rawValue:
      let service = self.treatments.value[indexPath.row]
      guard let index = self.selectedServicesIds.value.index(of: service.id) else { return }
      self.selectedServicesIds.value.remove(at: index)
    default:
      break
    }
  }

}
