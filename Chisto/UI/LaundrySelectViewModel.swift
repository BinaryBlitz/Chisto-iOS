//
//  LaundrySelectViewModel.swift
//  Chisto
//
//  Created by Алексей on 27.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias LaundrySelectSectionModel = SectionModel<String, LaundrySelectTableViewCellModelType>

struct Laundry {
  let name: String
  let description: String
  let rating: Float
  let courierDate: String
  let courierTimeInterval: String
  let deliveryDate: String
  let deliveryPrice: Int
  let cost: Int
  let type: LaundryType
}

enum LaundryType {
  case premium
  case fast
  case cheap
}

protocol LaundrySelectViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var filtersButtonDidTap: PublishSubject<Void> { get }
  
  // Output
  var navigationBarTitle: String { get }
  var sections: Driver<[LaundrySelectSectionModel]> { get }
  var presentSelectFilterSection: Driver<Void> { get }
  
  // Data
  var laundries: Variable<[Laundry]> { get }
}

class LaundrySelectViewModel: LaundrySelectViewModelType {
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  var filtersButtonDidTap = PublishSubject<Void>()
  
  // Output
  var navigationBarTitle = "Прачечные"
  var sections: Driver<[LaundrySelectSectionModel]>
  var presentSelectFilterSection: Driver<Void>
  
  // Data
  var laundries: Variable<[Laundry]>
  
  init() {
    let testLaundries = [Laundry(name: "Bianka", description: "Химчистка премиум класса № 1", rating: 3.5, courierDate: "15.09.2016", courierTimeInterval: "с 11:00 до 20:00", deliveryDate: "11.09.2016", deliveryPrice: 0, cost: 3400, type: .premium),
      Laundry(name: "Диана", description: "Cеть химчисток-прачечных", rating: 3, courierDate: "10.09.2016", courierTimeInterval: "24 часа", deliveryDate: "12.09.2016", deliveryPrice: 360, cost: 3800, type: .fast),
      Laundry(name: "Юлайм", description: "Чистка и глажение одежды", rating: 5, courierDate: "10.09.2016", courierTimeInterval: "24 часа", deliveryDate: "12.09.2016", deliveryPrice: 360, cost: 3800, type: .cheap)
    ]
    let laundries = Variable<[Laundry]>(testLaundries)
    self.laundries = laundries
    
    self.sections = laundries.asDriver().map { laundries in
      let cellModels = laundries.map(LaundrySelectTableViewCellModel.init) as [LaundrySelectTableViewCellModelType]
      
      let section = LaundrySelectSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.presentSelectFilterSection = filtersButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
  }

}
