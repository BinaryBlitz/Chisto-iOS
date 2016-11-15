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
  var selectedServices: Variable<[Treatment]> { get }
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
  var returnToSection: Driver<NewSection>

  // Data
  enum NewSection {
    case orderItem
    case order
  }

  var selectedServicesIds: Variable<[Int]>
  var treatments: Variable<[Treatment]>
  var selectedServices: Variable<[Treatment]>

  init(item: OrderItem, saveNeeded: Bool = true, selectedTreatments: [Treatment] = []) {
    let clothesItem = item.clothesItem

    DataManager.instance.fetchClothesTreatments(item: clothesItem).subscribe().addDisposableTo(disposeBag)

    let treatments = Variable<[Treatment]>([])

    Observable.from(clothesItem.treatments)
      .map { Array($0) }
      .bindTo(treatments)
      .addDisposableTo(disposeBag)

    self.treatments = treatments

    self.itemTitle = clothesItem.name
    self.color = UIColor.chsRosePink

    let selectedServicesIds = Variable<[Int]>(selectedTreatments.map { $0.id })
    self.selectedServicesIds = selectedServicesIds

    let selectedServices = Variable(selectedTreatments)
    self.selectedServices = selectedServices

    Observable.combineLatest(treatments.asObservable(), selectedServicesIds.asObservable()) { treatments, selectedServicesIds in
      return treatments.filter { selectedServicesIds.contains($0.id) }
    }.bindTo(selectedServices).addDisposableTo(disposeBag)

    self.sections = Driver.combineLatest(treatments.asDriver(), selectedServicesIds.asDriver()) { services, selectedServicesIds in
      let cellModels = services.map { service in
        ServiceSelectTableViewCellModel(treatment: service, isSelected: selectedServicesIds.index(of: service.id) != nil)
      } as [ServiceSelectTableViewCellModelType]

      let section = ServiceSelectSectionModel(model: "", items: cellModels)
      return [section]
    }

    self.returnToSection = readyButtonTapped.asObservable().map {
      if saveNeeded {
        OrderManager.instance.updateOrderItem(item: item) {
          item.treatments = selectedServices.value
        }
        return .order
      }
      return .orderItem
    }.asDriver(onErrorDriveWith: .empty())


    self.itemDidSelect.asObservable().subscribe(onNext: { indexPath in
      let service = self.treatments.value[indexPath.row]
      self.selectedServicesIds.value.append(service.id)
    }).addDisposableTo(disposeBag)

    self.itemDidDeselect.asObservable().subscribe(onNext: { indexPath in
      let service = self.treatments.value[indexPath.row]
      guard let index = self.selectedServicesIds.value.index(of: service.id) else { return }
      self.selectedServicesIds.value.remove(at: index)
    }).addDisposableTo(disposeBag)
  }

}
