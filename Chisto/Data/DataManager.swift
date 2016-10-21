//
//  DataManager.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrderItem {
  var clothesItem: ClothesItem
  var services: Variable<[Service]>
  var amount: Int
  init (clothesItem: ClothesItem, services: [Service], amount: Int = 1) {
    self.clothesItem = clothesItem
    self.services = Variable<[Service]>(services)
    self.amount = amount
  }
}

class DataManager {
  static let instance = DataManager()
  
  var currentOrderItems = Variable<[OrderItem]>([])
}
