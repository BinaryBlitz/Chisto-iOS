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

enum LaundrySortType {
  case byPrice
  case bySpeed
  case byRating
}

struct LaundrySortItem {
  var type: LaundrySortType
  var title: String
}

typealias LaundrySortSectionModel = SectionModel<String, LaundrySortItem>

class LaundrySortViewModel {
  let disposeBag = DisposeBag()
  // Input
  var itemDidSelect = PublishSubject<IndexPath>()
  
  // Output
  var sections: Driver<[LaundrySortSectionModel]>
  var dismissViewController: Driver<Void>
  
  // Data
  var selectedSortType = PublishSubject<LaundrySortType>()
  
  var sortItems = Variable([LaundrySortItem(type: .byPrice, title: "По цене"), LaundrySortItem(type: .bySpeed, title: "По скорости"), LaundrySortItem(type: .byRating, title: "По рейтингу")])
  
  init() {
    self.dismissViewController = itemDidSelect.asObservable().map { _ in Void() }.asDriver(onErrorDriveWith: .empty())
    
    self.sections = sortItems.asDriver().map { sortItems in
      
      let section = SectionModel(model: "", items: sortItems)
      return [section]
    }
    
    itemDidSelect.asObservable().subscribe(onNext: { [weak self] indexPath in
      guard let sortItem = self?.sortItems.value[indexPath.row] else { return }
      self?.selectedSortType.onNext(sortItem.type)
    }).addDisposableTo(disposeBag)
    
  }
}
