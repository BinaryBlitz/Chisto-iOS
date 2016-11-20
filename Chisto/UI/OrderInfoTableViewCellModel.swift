//
//  OrderInfoTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 20.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

protocol OrderInfoTableViewCellModelType {
  var clothesIconUrl: URL? { get }
  var clothesTitle: String { get }
  var clothesPrice: String { get }
}

class OrderInfoTableViewCellModel: OrderInfoTableViewCellModelType {
  
  let clothesIconUrl: URL? = nil
  let clothesTitle: String = ""
  let clothesPrice: String = ""
  
  init() {
  }
  
}
