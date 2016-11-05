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
  var id = UUID().hashValue
  var name = ""
  var description = ""
  
  static let defaultServices = [
    Service(name: "Декор", description: "Декоративная отделка"),
    Service(name: "Химчистка", description: "Только нежные растворители"),
    Service(name: "Стирка", description: "Стирка при температуре не выше 30"),
    Service(name: "Глажка", description: "Низкая температура 110  С"),
    Service(name: "Подшить", description: "Ушьем за 2 минуты")
  ]
  
  init(name: String, description: String) {
    self.name = name
    self.description = description
  }
  
  func price(laundry: Laundry) -> Int {
    var price = 0
    laundry.treatments.filter { $0.treatmentId == self.id }
      .forEach { price += $0.price }
    return price
  }
  
  func priceString(laundry: Laundry) -> String {
    let price = self.price(laundry: laundry)
    return price == 0 ? "Бесплатно" : "\(price) ₽"
  }
}

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
  var selectedServices: Variable<[Service]> { get }
}

class ServiceSelectViewModel: ServiceSelectViewModelType {
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
  var services: Variable<[Service]>
  var selectedServices: Variable<[Service]>
  
  let disposeBag = DisposeBag()
  
  init(item: OrderItem, saveNeeded: Bool = true, selectedServices: [Service] = []) {
    let clothesItem = item.clothesItem
    self.itemTitle = clothesItem.name
    self.color = UIColor.chsRosePink
    
    let services = Variable<[Service]>(Service.defaultServices)
    self.services = services
    
    let selectedServicesIds = Variable<[Int]>(selectedServices.map { $0.id })
    self.selectedServicesIds = selectedServicesIds
    
    let selectedServices = Variable(selectedServices)
    self.selectedServices = selectedServices
    
    selectedServicesIds.asObservable().map { servicesIds in
      return services.value.filter { servicesIds.contains($0.id) }
    }.bindTo(selectedServices).addDisposableTo(disposeBag)
    
    self.sections = Driver.combineLatest(services.asDriver(), selectedServicesIds.asDriver()) { services, selectedServicesIds in
      let cellModels = services.map { service in
        ServiceSelectTableViewCellModel(service: service, isSelected: selectedServicesIds.index(of: service.id) != nil)
      } as [ServiceSelectTableViewCellModelType]
      
      let section = ServiceSelectSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.returnToSection = readyButtonTapped.asObservable().map {
      if saveNeeded {
        OrderManager.instance.updateOrderItem(item: item) {
          item.services = selectedServices.value
        }
        return .order
      }
      return .orderItem
    }.asDriver(onErrorDriveWith: .empty())

    
    self.itemDidSelect.asObservable().subscribe(onNext: { indexPath in
      let service = self.services.value[indexPath.row]
      self.selectedServicesIds.value.append(service.id)
    }).addDisposableTo(disposeBag)
    
    self.itemDidDeselect.asObservable().subscribe(onNext: { indexPath in
      let service = self.services.value[indexPath.row]
      guard let index = self.selectedServicesIds.value.index(of: service.id) else { return }
      self.selectedServicesIds.value.remove(at: index)
    }).addDisposableTo(disposeBag)
    
  }

}
