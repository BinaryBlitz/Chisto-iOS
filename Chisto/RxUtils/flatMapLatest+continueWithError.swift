//
//  flatMapLatest+continueWithError.swift
//  Chisto
//
//  Created by Алексей on 17.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
  
  func catchErrorAndContinue(handler: @escaping (Error) throws -> Void) -> RxSwift.Observable<Self.E> {
    return self.catchError { error in
      try handler(error)
      return Observable.error(error)
    }.retry()
  }

}

