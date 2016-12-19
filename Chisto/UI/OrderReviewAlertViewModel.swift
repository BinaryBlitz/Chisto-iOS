//
//  OrderReviewAlertViewModel.swift
//  Chisto
//
//  Created by Алексей on 19.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class OrderReviewAlertViewModel {
  let title: String
  let ratingStarsCount: Variable<Int>

  let reviewContent: Variable<String?>
  let continueButtonDidTap = PublishSubject<Void>()
  let cancelButtonDidTap = PublishSubject<Void>()

  let dismissViewController: Driver<Void>

  let uiEnabled: Variable<Bool>

  init(order: Order) {
    self.title = "Заказ № \(order.id) исполнен!"
    let ratingStarsCount = Variable(0)
    self.ratingStarsCount = ratingStarsCount

    let reviewContent = Variable<String?>("")
    self.reviewContent = reviewContent

    let uiEnabled = Variable(true)
    self.uiEnabled = uiEnabled

    let continueButtonDriver = continueButtonDidTap.asDriver(onErrorDriveWith: .empty())
    let cancelButtonDriver = cancelButtonDidTap.asDriver(onErrorDriveWith: .empty())

    let didCreateReview = continueButtonDriver.flatMap { _ -> Driver<Void> in
      let rating = Rating()
      rating.content = reviewContent.value ?? ""
      rating.value = ratingStarsCount.value
      let createRating = DataManager.instance.createRating(laundryId: order.laundryId, rating: rating).asDriver(onErrorDriveWith: .just())
      return createRating.do(onNext: {
        uiEnabled.value = true
      }, onSubscribe: {
        uiEnabled.value = false
      })
    }

    self.dismissViewController = Driver.of(didCreateReview, cancelButtonDriver).merge().map {
      guard let order = ProfileManager.instance.userProfile.value.order else { return }
      let realm = try! Realm()
      try! realm.write {
        order.ratingRequired = false
      }
    }
  }
}
