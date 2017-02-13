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
  var promoCode = Variable<PromoCode?>(nil)
  var promoCodePriceDiscount: Observable<String>
  let headerViewDidTap = PublishSubject<Void>()
  let promoCodeButtonDidTap = PublishSubject<Void>()

  let ratingCountLabels = [NSLocalizedString("ratingNominitive", comment: "Ratings count"), NSLocalizedString("ratingGenitive", comment: "Ratings count"), NSLocalizedString("ratingsGenitive", comment: "Ratings count")]

  init(laundry: Laundry) {
    let price = OrderManager.instance.price(laundry: laundry)
    self.orderPrice = price.currencyString
    let collectionPrice = laundry.collectionPrice(amount: price)
    self.collectionPrice = collectionPrice > 0 ? collectionPrice.currencyString : NSLocalizedString("freeCollectionPrice", comment: "Order confirm screen")
    self.promoCodePriceDiscount = promoCode.asObservable().filter { $0 != nil }.map { promoCode in
      let discount = OrderManager.instance.price(laundry: laundry, includeCollection: true, promoCode: promoCode) - OrderManager.instance.price(laundry: laundry, includeCollection: true)
      return discount.currencyString
    }
  }

}
