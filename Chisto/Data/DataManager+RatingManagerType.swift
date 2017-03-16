//
//  DataManager+RatingManagerType.swift
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

protocol RatingManagerType {
  func createRating(laundryId: Int, rating: Rating) -> Observable<Void>
  func updateRating(rating: Rating) -> Observable<Void>
}

extension DataManager: RatingManagerType {
  func createRating(laundryId: Int, rating: Rating) -> Observable<Void> {
    let json = rating.toJSON()

    return networkRequest(method: .post, .createRating(laundryId: laundryId), ["rating": json]).map { _ in }
  }

  func updateRating(rating: Rating) -> Observable<Void> {
    let realm = try! Realm()
    var json: [String: Any] = [:]
    try? realm.write {
      json = rating.toJSON()
    }

    return networkRequest(method: .patch, .updateRating(ratingId: rating.id), ["rating": json]).map { _ in }
  }
}
