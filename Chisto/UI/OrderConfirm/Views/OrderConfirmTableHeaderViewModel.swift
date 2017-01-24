//
//  OrderConfirmTableHeaderViewModel.swift
//  Chisto
//
//  Created by Алексей on 21.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OrderConfirmTableHeaderViewModel {
  var laundryDescriprionTitle: String
  var laundryIcon: URL?  = nil
  var laundryBackground: URL? = nil
  var promoCode = Variable<String?>(nil)
  var laundryRating: Float
  var ratingsCountText: String
  var collectionDate: String
  var collectionTime: String
  var collectionPrice: String
  var orderPrice: String
  var deliveryDate: String
  let deliveryTime: String
  let headerViewDidTap = PublishSubject<Void>()
  let promoCodeButtonDidTap = PublishSubject<Void>()

  let ratingCountLabels = ["отзыв", "отзыва", "отзывов"]

  init(laundry: Laundry) {
    self.laundryDescriprionTitle = laundry.descriptionText
    self.laundryRating = laundry.rating
    self.ratingsCountText = "\(laundry.ratingsCount) " + getRussianNumEnding(number: laundry.ratingsCount, endings: ratingCountLabels)
    self.laundryIcon = URL(string: laundry.logoUrl)
    self.laundryBackground = URL(string: laundry.backgroundImageUrl)
    self.collectionDate = laundry.collectionDate.shortDate
    let price = OrderManager.instance.price(laundry: laundry)
    let collectionPrice = laundry.collectionPrice(amount: price)
    self.collectionPrice = collectionPrice > 0 ? collectionPrice.currencyString : "Бесплатно"
    self.deliveryDate = laundry.deliveryDate.shortDate
    self.orderPrice = price.currencyString
    self.deliveryTime = laundry.deliveryTimeInterval
    self.collectionTime = laundry.collectionTimeInterval

  }

}
