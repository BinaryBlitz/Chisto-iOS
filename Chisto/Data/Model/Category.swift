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
import ObjectMapper_Realm

class Category: ServerObject {

  @objc dynamic var name: String = ""
  @objc dynamic var colorString: String = ""
  @objc dynamic var iconUrl: String = ""
  @objc dynamic var descriptionText: String = ""
  var itemsPreview = List<RealmString>()
  @objc dynamic var itemsCount: Int = 0
  @objc dynamic var featured: Bool = false

  var color: UIColor {
    return UIColor(colorString)
  }

  let clothes = LinkingObjects(fromType: Item.self, property: "category")

  override func mapping(map: Map) {
    super.mapping(map: map)

    name <- map["name"]
    colorString <- map["color"]
    descriptionText <- map["description"]
    iconUrl <- map["icon_url"]
    itemsCount <- map["items_count"]
    featured <- map["featured"]

    var itemsPreview: [String]? = nil
    itemsPreview <- map["items_preview"]
    let newList = List<RealmString>()
    itemsPreview?.forEach { item in
      let value = RealmString()
      value.stringValue = item
      newList.append(value)
    }
    self.itemsPreview = newList
  }

}
