//
//  RealmManager.swift
//  Chisto
//
//  Created by Алексей on 21.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
  static let instance = RealmManager()
  var uiRealm: Realm

  init() {
    let config = Realm.Configuration(
      schemaVersion: 9,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 6 {
          migration.renameProperty(onType: Profile.className(), from: "street", to: "streetName")
          migration.renameProperty(onType: Payment.className(), from: "isPaid", to: "paid")
          migration.renameProperty(onType: Laundry.className(), from: "minOrderPrice", to: "minimumOrderPrice")
          migration.renameProperty(onType: Item.className(), from: "icon", to: "iconUrl")
          migration.renameProperty(onType: Category.className(), from: "icon", to: "iconUrl")

        }

      })
    Realm.Configuration.defaultConfiguration = config
    uiRealm = try! Realm()
  }
}
