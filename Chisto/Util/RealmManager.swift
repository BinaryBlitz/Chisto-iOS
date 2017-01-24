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
      schemaVersion: 2,
      migrationBlock: { migration, oldSchemaVersion in

    })
    Realm.Configuration.defaultConfiguration = config
    uiRealm = try! Realm()
  }
}
