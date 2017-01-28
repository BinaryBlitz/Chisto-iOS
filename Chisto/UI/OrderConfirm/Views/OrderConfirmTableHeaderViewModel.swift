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
  var collectionPrice: String
  var orderPrice: String
  var promoCode = Variable<String?>(nil)
  let promoCodeButtonDidTap = PublishSubject<Void>()

  let ratingCountLabels = ["ratingNominitive".localized, "ratingGenitive".localized, "ratingsGenitive".localized]

  init(laundry: Laundry) {
    let price = OrderManager.instance.price(laundry: laundry)
    self.orderPrice = price.currencyString
    let collectionPrice = laundry.collectionPrice(amount: price)
    self.collectionPrice = collectionPrice > 0 ? collectionPrice.currencyString : "free".localized
  }

}
