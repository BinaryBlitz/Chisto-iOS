//
//  LastTimePopupViewModel.swift
//  Chisto
//
//  Created by Алексей on 25.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class LastTimePopupViewModel {
  let laundryDescriptionViewModels: [LaundryItemInfoViewModel]
  
  init() {
    let courierItemViewModel = LaundryItemInfoViewModel(type: .courier, titleText: "15.09.2016", subTitleText: "Бесплатно")
    let deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: "11.09.2016", subTitleText: "с 11:00 до 20:00")
    let costItemViewModel = LaundryItemInfoViewModel(type: .cost, titleText: "3 400 ₽")
    
    self.laundryDescriptionViewModels = [courierItemViewModel, deliveryItemViewModel, costItemViewModel]
  }
}
