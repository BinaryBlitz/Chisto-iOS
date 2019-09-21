//
//  RxRealm+ObjectForPrimaryKey.swift
//  Chisto
//
//  Created by Алексей on 18.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

extension Realm {
  func observableObject<T:Object, K:
Any>(

type: T.Type, primaryKey: K) -> Observable<T?> {
  guard let primaryKeyName = type.primaryKey() else {
    fatalError("At present you can't observe objects that don't have primary key.")
  }

  return Observable.create { observer in
    let objectQuery = self.objects(type)
      .filter("%K == %@", primaryKeyName, primaryKey)

    let token = objectQuery.observe { changes in
      switch changes {
      case .initial(let results):
        if let latestObject = results.first {
          observer.onNext(latestObject)
        } else {
          observer.onError(RxRealmError.objectDeleted)
        }
      case .update(let results, _, _, _):
        if let latestObject = results.first {
          observer.onNext(latestObject)
        } else {
          observer.onError(RxRealmError.objectDeleted)
        }
      case .error(let error):
        observer.onError(error)
      }
    }

    return Disposables.create {
        token.invalidate()
    }
  }
}
}
