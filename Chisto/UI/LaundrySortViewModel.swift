//
//  LaundrySortModalViewModel.swift
//  Chisto
//
//  Created by Алексей on 28.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum SortType {
  case byPrice
  case bySpeed
  case byRating
}

struct SortItem {
  var type: SortType
  var title: String
}

typealias LaundrySortSectionModel = SectionModel<String, SortItem>

class LaundrySortViewModel {
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  
  // Output
  var sections: Driver<[LaundrySortSectionModel]>
  var dismissViewController: Driver<Void>
  
  var sortItems = Variable([SortItem(type: .byPrice, title: "По цене"), SortItem(type: .bySpeed, title: "По скорости"), SortItem(type: .byRating, title: "По рейтингу")])
  
  init() {
    self.dismissViewController = itemDidSelect.asObservable().map { _ in Void() }.asDriver(onErrorDriveWith: .empty())
    
    self.sections = sortItems.asDriver().map { sortItems in
      
      let section = SectionModel(model: "", items: sortItems)
      return [section]
    }
  }
}
