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
import UIColor_Hex_Swift
import ObjectMapper

class Category: ServerObject {

  dynamic var name: String = ""
  dynamic var colorString: String = ""
  dynamic var icon: String = ""
  dynamic var descriptionText: String = ""
  dynamic var featured: Bool = false
  
  var color: UIColor {
    return UIColor(colorString)
  }

  let clothes = LinkingObjects(fromType: Item.self, property: "category")

  override func mapping(map: Map) {
    super.mapping(map: map)

    name <- map["name"]
    colorString <- map["color"]
    descriptionText <- map["description"]
    icon <- map["icon_url"]
    featured <- map["featured"]
  }

}
