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
    order.map { $0.createdAt.mediumDate }.bind(to: self.orderDate).addDisposableTo(disposeBag)
    order.map { $0.status?.description ?? "" }.bind(to: self.orderStatus).addDisposableTo(disposeBag)
    order.map { $0.status?.image }.bind(to: self.orderStatusIcon).addDisposableTo(disposeBag)
    order.map { $0.status?.color ?? .chsSkyBlue }.bind(to: self.orderStatusColor).addDisposableTo(disposeBag)

    order.map { $0.deliveryPriceString }.bind(to: deliveryPrice).addDisposableTo(disposeBag)
    order.map { $0.orderPrice.currencyString }.bind(to: orderPrice).addDisposableTo(disposeBag)
    order.map { $0.totalPrice.currencyString }.bind(to: totalprice).addDisposableTo(disposeBag)
    order.map { $0.paymentMethod.description }.bind(to: paymentType).addDisposableTo(disposeBag)
    order.map { $0.paymentMethod.image }.bind(to: paymentMethodImage).addDisposableTo(disposeBag)
    order.map { $0.promoCode?.code }.bind(to: promoCodeText).addDisposableTo(disposeBag)
    order.map { $0.promoCode }.bind(to: promoCode).addDisposableTo(disposeBag)
    order.map { $0.promoCodeDiscount.currencyString }.bind(to: promoCodeDiscount).addDisposableTo(disposeBag)

    let realm = RealmManager.instance.uiRealm

    let observableOrderLaundry = order.map { realm.object(ofType: Laundry.self, forPrimaryKey: $0.laundryId) }
    observableOrderLaundry.map { $0?.name }.bind(to: laundryTitle).addDisposableTo(disposeBag)
    observableOrderLaundry.map { $0?.descriptionText }.bind(to: laundryDescriprion).addDisposableTo(disposeBag)
    observableOrderLaundry.map { URL(string: $0?.logoUrl ?? "") }.bind(to: laundryIcon).addDisposableTo(disposeBag)
  }
}
