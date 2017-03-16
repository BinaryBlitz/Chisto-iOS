//
//  DataManager+UserManagerType.swift
//  Chisto
//
//  Created by Алексей on 16.03.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import RxSwift
import RxCocoa
import RxRealm
import SwiftyJSON
import ObjectMapper

protocol UserManagerType {
  func updateUser() -> Observable<Void>
  func showUser() -> Observable<Void>
  func createUser() -> Observable<Void>
}

extension DataManager: UserManagerType {
  func createUser() -> Observable<Void> {
    let profile = ProfileManager.instance.userProfile.value
    let realm = try! Realm()
    var jsonProfile: [String: Any] = [:]
    try? realm.write {
      jsonProfile["user"] = profile.toJSON()
    }
    return networkRequest(method: .post, .createUser, jsonProfile).map { json in
      guard let jsonMap = json as? [String: Any] else { throw DataError.responseConvertError }

      ProfileManager.instance.updateProfile { profile in
        let map = Map(mappingType: .fromJSON, JSON: jsonMap)
        profile.mapping(map: map)
        profile.isCreated = true
      }
    }
  }

  func showUser() -> Observable<Void> {
    guard ProfileManager.instance.userProfile.value.apiToken != nil else { return Observable.just(()) }
    return networkRequest(method: .get, .showUser).map { json in
      guard let jsonMap = json as? [String: Any] else { throw DataError.responseConvertError }
      let realm = try! Realm()

      let order = Mapper<Order>().map(JSONObject: jsonMap["order"])
      if let order = order {
        try! realm.write { realm.add(order, update: true) }
      }

      ProfileManager.instance.updateProfile { profile in
        let map = Map(mappingType: .fromJSON, JSON: jsonMap)
        profile.mapping(map: map)
        profile.isCreated = true
        profile.order = order
      }
    }
  }

  func updateUser() -> Observable<Void> {
    let profile = ProfileManager.instance.userProfile.value
    let realm = try! Realm()
    var jsonProfile: [String: Any] = [:]
    try? realm.write {
      jsonProfile["user"] = profile.toJSON()
    }
    return networkRequest(method: .patch, .updateUser, jsonProfile).map { _ in }
  }
}
