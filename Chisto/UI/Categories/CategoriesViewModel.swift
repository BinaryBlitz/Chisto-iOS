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

struct Category {
  var name = ""
  var icon: UIImage? = nil
  var subCategories: [String] = []
}

typealias CategoriesSectionModel = SectionModel<String, CategoryTableViewCellModelType>

protocol CategoriesViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  
  // Output
  var navigationBarTitle: String { get }
  var sections: Driver<[CategoriesSectionModel]> { get }
  var presentItemsSection: Driver<Void> { get }
}

class CategoriesViewModel: CategoriesViewModelType {
  
  var defaultCategories = [
    Category(name: "Головные уборы", icon: #imageLiteral(resourceName: "iconHeats"),
             subCategories: ["Шапки","Береты", "Кепки", "Шляпы", "Косынки"]),
    Category(name: "Обувь", icon: #imageLiteral(resourceName: "iconShoes"),
             subCategories: ["Кроссовки", "Туфли", "Сапоги", "Кеды", "Сандалии", "", "", ""]),
    Category(name: "Верхняя одежда", icon: #imageLiteral(resourceName: "iconOuterwear"),
             subCategories: ["Дубленки", "Куртки", "Пальто", "Анораки", "Сандалии", ""]),
    Category(name: "Брюки", icon: #imageLiteral(resourceName: "iconTrousers"),
             subCategories: ["Джинсы", "Леггинсы", "Шорты", ""]),
    ]
  
  private let disposeBag = DisposeBag()
  
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  
  // Output
  var navigationBarTitle: String
  var sections: Driver<[CategoriesSectionModel]>
  var presentItemsSection: Driver<Void>
  
  
  // Data
  var categories: Variable<[Category]>
  
  init() {
    self.navigationBarTitle = "Выбор вещи"
    
    self.categories = Variable<[Category]>(defaultCategories)
    
    self.sections = categories.asDriver().map { categories in
      let cellModels = categories.map(CategoryTableViewCellModel.init) as [CategoryTableViewCellModelType]
      
      let section = CategoriesSectionModel(model: "", items: cellModels)
      return [section]
    }
    
    self.presentItemsSection = itemDidSelect.map{_ in Void()}.asDriver(onErrorDriveWith: .empty())
    
  }
  
  
}
