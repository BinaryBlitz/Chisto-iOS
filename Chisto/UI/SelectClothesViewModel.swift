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

struct ClothesItem {
  var name = ""
  var icon: UIImage? = nil
  var relatedItems: [String] = []
}

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
  
  var defaultClothesItems: [ClothesItem] = [
    ClothesItem(name: "Шапка", icon: #imageLiteral(resourceName: "iconHat"),
             relatedItems: ["Шапки зимние","Летние из трикотажа", "Хлопка", "Шерсти"]),
    ClothesItem(name: "Кепка", icon: #imageLiteral(resourceName: "iconCap"),
             relatedItems: ["Кепки", "Бейсболки", "Снэпбэки"]),
    ClothesItem(name: "Шляпа", icon: #imageLiteral(resourceName: "iconNap"),
             relatedItems: ["Лайкра", "Растительный материал", "Хлопок", "Шерсть", "Лен"])
    ]
  
  private let disposeBag = DisposeBag()
  
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  
  // Output
  var navigationBarTitle: String
  var navigationBarColor: UIColor?
  var sections: Driver<[SelectClothesSectionModel]>
  var presentSelectServiceSection: Driver<ServiceSelectViewModel>
  
  // Data
  var clothesItems: Variable<[ClothesItem]>
  
  init(category: Category) {
    self.navigationBarTitle = category.name
    self.navigationBarColor = category.color
    
    let clothesItems = Variable<[ClothesItem]>(defaultClothesItems)
    
    self.clothesItems = clothesItems
    
    self.sections = clothesItems.asDriver().map { clothesItems in
      let cellModels = clothesItems.map(SelectClothesTableViewCellModel.init) as [SelectClothesTableViewCellModelType]
      
      let section = SelectClothesSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.presentSelectServiceSection = itemDidSelect.map{ indexPath in
      let clothesItem = clothesItems.value[indexPath.row]
      let orderItem = OrderItem(clothesItem: clothesItem, services: [])
      return ServiceSelectViewModel(item: orderItem)
    }.asDriver(onErrorDriveWith: .empty())
    
  }
  
  
}
