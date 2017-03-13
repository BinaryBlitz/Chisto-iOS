//
//  OrderInfoTableHeaderViewModel.swift
//  Chisto
//
//  Created by Алексей on 22.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrderInfoTableHeaderViewModel {
  let disposeBag = DisposeBag()
  var laundryTitle = Variable<String?>("")
  var laundryDescriprion = Variable<String?>("")
  var laundryIcon = Variable<URL?>(nil)
  var orderNumber: String = ""
  var orderDate = Variable<String>("")
  var orderPrice = Variable<String>("...")
  var deliveryPrice = Variable<String>("...")
  var totalprice = Variable<String>("...")
  var orderStatus = Variable<String>("")
  var orderStatusIcon = Variable<UIImage?>(nil)
  var paymentType = Variable<String>("")
  var paymentMethodImage = Variable<UIImage?>(nil)
  var orderStatusColor = Variable<UIColor>(.chsSkyBlue)
  var promoCodeText = Variable<String?>("")
  var promoCodeDiscount = Variable<String>("")
  var promoCode = Variable<PromoCode?>(nil)

  let phoneNumber = "+7 495 766-78-49"

  init(order: Observable<Order>) {
    order.map { $0.createdAt.mediumDate }.bindTo(self.orderDate).addDisposableTo(disposeBag)
    order.map { $0.status?.description ?? "" }.bindTo(self.orderStatus).addDisposableTo(disposeBag)
    order.map { $0.status?.image }.bindTo(self.orderStatusIcon).addDisposableTo(disposeBag)
    order.map { $0.status?.color ?? .chsSkyBlue }.bindTo(self.orderStatusColor).addDisposableTo(disposeBag)

    order.map { $0.deliveryPriceString }.bindTo(deliveryPrice).addDisposableTo(disposeBag)
    order.map { $0.orderPrice.currencyString }.bindTo(orderPrice).addDisposableTo(disposeBag)
    order.map { $0.totalPrice.currencyString }.bindTo(totalprice).addDisposableTo(disposeBag)
    order.map { $0.paymentMethod.description }.bindTo(paymentType).addDisposableTo(disposeBag)
    order.map { $0.paymentMethod.image }.bindTo(paymentMethodImage).addDisposableTo(disposeBag)
    order.map { $0.promoCode?.code }.bindTo(promoCodeText).addDisposableTo(disposeBag)
    order.map { $0.promoCode }.bindTo(promoCode).addDisposableTo(disposeBag)
    order.map { $0.promoCodeDiscount.currencyString }.bindTo(promoCodeDiscount).addDisposableTo(disposeBag)

    let realm = RealmManager.instance.uiRealm

    let observableOrderLaundry = order.map { realm.object(ofType: Laundry.self, forPrimaryKey: $0.laundryId) }
    observableOrderLaundry.map { $0?.name }.bindTo(laundryTitle).addDisposableTo(disposeBag)
    observableOrderLaundry.map { $0?.descriptionText }.bindTo(laundryDescriprion).addDisposableTo(disposeBag)
    observableOrderLaundry.map { URL(string: $0?.logoUrl ?? "") }.bindTo(laundryIcon).addDisposableTo(disposeBag)
  }
}
