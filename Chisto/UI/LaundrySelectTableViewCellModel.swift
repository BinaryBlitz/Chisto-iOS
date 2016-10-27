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
  var laundryDescriptionViewModels: [LaundryItemInfoViewModel] { get }
  var laundryTitle: String { get }
  var laundryDescription: String { get }
  var rating: Float { get }
  var tagBgColor: UIColor? { get }
  var tagName: String? { get }

}

class LaundrySelectTableViewCellModel: LaundrySelectTableViewCellModelType {
  let laundryDescriptionViewModels: [LaundryItemInfoViewModel]
  let laundryTitle: String
  let laundryDescription: String
  let rating: Float
  let tagBgColor: UIColor?
  let tagName: String?
  let tagIsHidden: Bool = false
  
  init(laundry: Laundry) {
    self.laundryTitle = laundry.name
    self.laundryDescription = laundry.description
    self.rating = laundry.rating
    
    let courierItemViewModel = LaundryItemInfoViewModel(type: .courier, titleText: laundry.courierDate, subTitleText: laundry.courierTimeInterval)
    
    let deliveryPriceString = laundry.deliveryPrice > 0 ? "\(laundry.deliveryPrice) ₽" : "Бесплатно"
    let deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: laundry.deliveryDate, subTitleText: deliveryPriceString)
    
    // TODO: move this logic to model
    let costString = laundry.cost > 0 ? "\(laundry.cost) ₽" : "Бесплатно"
    let costItemViewModel = LaundryItemInfoViewModel(type: .cost, titleText: costString)
    
    switch laundry.type {
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
    
    self.laundryDescriptionViewModels = [courierItemViewModel, deliveryItemViewModel, costItemViewModel]

  }
  
}
