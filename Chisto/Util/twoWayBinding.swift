//
//  twoWayBinding.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <->

func <-><T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
  let bindToUIDisposable = variable.asObservable()
    .bind(to: property)
  let bindToVariable = property
    .subscribe(onNext: { nextValue in
    variable.value = nextValue
  }, onCompleted: {
    bindToUIDisposable.dispose()
  })

  return Disposables.create(bindToUIDisposable, bindToVariable)
}
