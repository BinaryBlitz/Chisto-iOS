//
//  Category.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

class Category: ServerObjct {
  dynamic var name: String = ""
  dynamic var color: String = ""
  dynamic var icon: String = ""
  dynamic var descriptionText: String = ""
  var subCategories = List<RealmString>()
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    descriptionText <- map["description"]
    icon <- map["icon"]
  }

}
