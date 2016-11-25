//
//  ItemInfoTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 21.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

protocol ItemInfoTableViewCellModelType {
  var serviceTitle: String { get }
  var serviceDescription: String { get }
  var countText: String { get }
}

class ItemInfoTableViewCellModel: ItemInfoTableViewCellModelType {

  var serviceTitle: String
  var serviceDescription: String
  var countText: String
  
  init(_ title: String, _ description: String, _ count: Int = 1) {
    self.serviceTitle = title
    self.serviceDescription = description
    self.countText = String(count)
  }

  init(treatment: Treatment, count: Int) {
    self.serviceTitle = treatment.name
    self.serviceDescription = treatment.descriptionText
    self.countText = String(count)
  }

}
