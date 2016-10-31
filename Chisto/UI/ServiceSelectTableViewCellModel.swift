//
//  ServiceSelectTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 19.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

protocol ServiceSelectTableViewCellModelType {
  var serviceTitle: String { get }
  var serviceDescription: String { get }
  var color: UIColor { get }
  var isSelected: Bool { get }
}

class ServiceSelectTableViewCellModel: ServiceSelectTableViewCellModelType {
  var isSelected: Bool
  var serviceTitle: String
  var serviceDescription: String
  var color: UIColor
  
  init(service: Service, isSelected: Bool) {
    self.serviceTitle = service.name
    self.serviceDescription = service.description
    self.color = UIColor.chsRosePink
    self.isSelected = isSelected
  }
}
