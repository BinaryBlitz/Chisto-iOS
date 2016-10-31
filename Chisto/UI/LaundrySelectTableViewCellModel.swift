//
//  LaundrySelectTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 27.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

protocol LaundrySelectTableViewCellModelType {
  var laundryTitle: String { get }
  var laundryDescription: String { get }
  var rating: Float { get }
  var tagBgColor: UIColor? { get }
  var tagName: String? { get }
  var tagIsHidden: Bool { get }
  var courierItemViewModel: LaundryItemInfoViewModel { get }
  var deliveryItemViewModel: LaundryItemInfoViewModel { get }
  var costItemViewModel: LaundryItemInfoViewModel { get }

}

class LaundrySelectTableViewCellModel: LaundrySelectTableViewCellModelType {
  let laundryTitle: String
  let laundryDescription: String
  let rating: Float
  var tagBgColor: UIColor? = nil
  var tagName: String? = nil
  var tagIsHidden: Bool = false
  var courierItemViewModel: LaundryItemInfoViewModel
  var deliveryItemViewModel: LaundryItemInfoViewModel
  var costItemViewModel: LaundryItemInfoViewModel

  
  init(laundry: Laundry) {
    self.laundryTitle = laundry.name
    self.laundryDescription = laundry.description
    self.rating = laundry.rating
    
    self.courierItemViewModel = LaundryItemInfoViewModel(type: .courier, titleText: laundry.courierDate, subTitleText: laundry.courierTimeInterval)
    
    let deliveryPriceString = laundry.deliveryPrice > 0 ? "\(laundry.deliveryPrice) ₽" : "Бесплатно"
    self.deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: laundry.deliveryDate, subTitleText: deliveryPriceString)
    
    // TODO: move this logic to model
    let costString = laundry.cost > 0 ? "\(laundry.cost) ₽" : "Бесплатно"
    self.costItemViewModel = LaundryItemInfoViewModel(type: .cost, titleText: costString)
    
    if let type = laundry.type {
      switch type {
      case .cheap:
        tagName = "Дешевая"
        tagBgColor = UIColor.chsAquaMarine
      case .fast:
        tagName = "Быстрая"
        tagBgColor = UIColor.chsMaize
      case .premium:
        tagName = "Премиум"
        tagBgColor = UIColor.chsRosePink
      }
    } else {
      self.tagIsHidden = false
    }
    
  }
  
}
