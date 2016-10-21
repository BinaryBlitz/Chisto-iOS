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

class Service {
  var id = UUID().uuidString
  var name = ""
  var description = ""
  
  init(name: String, description: String) {
    self.name = name
    self.description = description
  }
}

typealias ServiceSelectSectionModel = SectionModel<String, ServiceSelectTableViewCellModelType>

protocol ServiceSelectViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var itemDidDeSelect: PublishSubject<IndexPath> { get }
  var readyButtonTapped: PublishSubject<Void> { get }
  
  // Output
  var itemTitle: String { get }
  var color: UIColor { get }
  var sections: Driver<[ServiceSelectSectionModel]> { get }
  var selectedServicesIds: Variable<[String]> { get }
}

class ServiceSelectViewModel: ServiceSelectViewModelType {
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var itemDidDeSelect = PublishSubject<IndexPath>()
  var readyButtonTapped = PublishSubject<Void>()
  
  // Output
  var color: UIColor
  var navigationItemTitle = "Выбор услуг"
  var itemTitle: String
  var sections: Driver<[ServiceSelectSectionModel]>
  
  // Data
  var selectedServicesIds: Variable<[String]>
  var services: Variable<[Service]>
  var presentOrderSection: Driver<Void>
  
  let disposeBag = DisposeBag()
  
  init(item: OrderItem, isNew: Bool = true) {
    let clothesItem = item.clothesItem
    self.itemTitle = clothesItem.name
    self.color = UIColor.chsRosePink
    
    let defaultServices = [
      Service(name: "Химчистка", description: "Только нежные растворители"),
      Service(name: "Стирка", description: "Стирка при температуре не выше 30"),
      Service(name: "Глажка", description: "Низкая температура 110  С"),
      Service(name: "Подшить", description: "Ушьем за 2 минуты")
    ]
    
    let services = Variable<[Service]>(defaultServices)
    self.services = services
    
    let selectedServicesIds = Variable<[String]>(item.services.map { $0.id })
    self.selectedServicesIds = selectedServicesIds
    
    self.sections = services.asDriver().map { services in
      let cellModels = services.map(ServiceSelectTableViewCellModel.init) as [ServiceSelectTableViewCellModelType]
      let section = ServiceSelectSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.presentOrderSection = readyButtonTapped.asObservable().map {
      let services = services.value.filter { selectedServicesIds.value.index(of: $0.id) != nil }
      item.services = services
      if isNew {
        DataManager.instance.currentOrderItems.value.append(item)
      }
    }.asDriver(onErrorDriveWith: .empty())

    
    self.itemDidSelect.asObservable().subscribe(onNext: { indexPath in
      let service = self.services.value[indexPath.row]
      self.selectedServicesIds.value.append(service.id)
    }).addDisposableTo(disposeBag)
    
    self.itemDidDeSelect.asObservable().subscribe(onNext: { indexPath in
      let service = self.services.value[indexPath.row]
      guard let index = self.selectedServicesIds.value.index(of: service.id) else { return }
      self.selectedServicesIds.value.remove(at: index)
    }).addDisposableTo(disposeBag)
    
  }

}
