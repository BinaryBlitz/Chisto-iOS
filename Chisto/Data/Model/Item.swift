//
//  Clothes.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

class Item: ServerObject {
  dynamic var name: String = ""
  dynamic var icon: String = ""
  dynamic var descriptionText: String = ""
  dynamic var hasDecoration: Bool = true
  dynamic var useArea: Bool = false
  dynamic var longTreatment: Bool = false
  dynamic var category: Category? = nil

  let treatments = LinkingObjects(fromType: Treatment.self, property: "item")

  override func mapping(map: Map) {
    super.mapping(map: map)

    name <- map["name"]
    descriptionText <- map["description"]
    icon <- map["icon_url"]
    useArea <- map["use_area"]
    longTreatment <- map["long_treatment"]
    guard category == nil else { return }
    var categoryId: Int? = nil
    categoryId <- map["category_id"]
    let realm = try! Realm()
    category = realm.object(ofType: Category.self, forPrimaryKey: categoryId)
  }
}
