//
//  LineItem.swift
//  Chisto
//
//  Created by Алексей on 19.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm

class LineItem: ServerObjct {
  dynamic var laundryTtreatment: LaundryTreatment?
  dynamic var price: Int = 0
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    
    laundryTtreatment <- map["laundry_treatment"]
    price <- map["price"]
  }
  
}
