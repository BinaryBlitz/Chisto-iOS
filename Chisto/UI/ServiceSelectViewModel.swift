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

struct Service {
  var name = ""
  var description = ""
}

typealias ServiceSelectSectionModel = SectionModel<String, ServiceSelectTableViewCellModelType>

protocol ServiceSelectViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var readyButtonTapped: PublishSubject<IndexPath> { get }
  
  // Output
  var itemTitle: String { get }
  var color: UIColor { get }
  var sections: Driver<[ServiceSelectSectionModel]> { get }
}

class ServiceSelectViewModel: ServiceSelectViewModelType {
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var readyButtonTapped = PublishSubject<IndexPath>()
  
  // Output
  var color: UIColor
  var itemTitle: String
  var sections: Driver<[ServiceSelectSectionModel]>
  
  // Data
  var services: Variable<[Service]>
  
  init(item: String) {
    self.itemTitle = item
    self.color = UIColor.chsRosePink
    let defaultServices = [
      Service(name: "Химчистка", description: "Только нежные растворители"),
      Service(name: "Стирка", description: "Стирка при температуре не выше 30"),
      Service(name: "Глажка", description: "Низкая температура 110  С"),
      Service(name: "Глажка", description: "Ушьем за 2 минуты")
    ]
    
    self.services = Variable<[Service]>(defaultServices)
    
    self.sections = services.asDriver().map { services in
      let cellModels = services.map(ServiceSelectTableViewCellModel.init) as [ServiceSelectTableViewCellModelType]
      let section = ServiceSelectSectionModel(model: "", items: cellModels)
      return [section]
    }
    
  }

}
