//
//  LaundrySelectTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 27.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

protocol LaundrySelectTableViewCellModelType {
  var laundryTitle: String { get }
  var laundryDescription: String { get }
  var rating: Float { get }
  var tagBgColor: UIColor? { get }
  var tagName: String? { get }
  var tagIsHidden: Bool { get }
  var isDisabled: Bool { get }
  var logoUrl: URL? { get }
  var disabledColor: UIColor { get }
  var collectionItemViewModel: LaundryItemInfoViewModel { get }
  var deliveryItemViewModel: LaundryItemInfoViewModel { get }
  var costItemViewModel: LaundryItemInfoViewModel { get }
}

class LaundrySelectTableViewCellModel: LaundrySelectTableViewCellModelType {

  let laundryTitle: String
  let laundryDescription: String
  let rating: Float
  var tagBgColor: UIColor? = nil
  var tagName: String? = nil
  var disabledColor: UIColor = UIColor.chsCoolGrey
  var tagIsHidden: Bool = false
  var isDisabled: Bool = true
  var logoUrl: URL?
  var collectionItemViewModel: LaundryItemInfoViewModel
  var deliveryItemViewModel: LaundryItemInfoViewModel
  var costItemViewModel: LaundryItemInfoViewModel

  init(laundry: Laundry, type: LaundryType?) {
    var price = OrderManager.instance.price(laundry: laundry, includeCollection: false)
    let isDisabled = price < laundry.minOrderPrice
    self.isDisabled = isDisabled
    self.laundryTitle = laundry.name
    self.laundryDescription = laundry.descriptionText
    self.rating = laundry.rating
    self.logoUrl = URL(string: laundry.logoUrl)

    let collectionDateString = laundry.collectionDate.shortDate
    self.collectionItemViewModel = LaundryItemInfoViewModel(type: .collection, titleText: collectionDateString, subTitleText: laundry.deliveryTimeInterval, isDisabled: isDisabled)

    let deliveryDateString = laundry.deliveryDate.shortDate
    self.deliveryItemViewModel = LaundryItemInfoViewModel(type: .delivery, titleText: deliveryDateString, subTitleText: laundry.deliveryTimeInterval, isDisabled: isDisabled)

    let collectionPrice = OrderManager.instance.collectionPrice(laundry: laundry)
    price += collectionPrice
    let costString = price.currencyString

    if !isDisabled {
      self.costItemViewModel = LaundryItemInfoViewModel(type: .cost, titleText: costString)
    } else {
      let titleText = "Минимальная сумма заказа"
      let subTitleText = "\((laundry.minOrderPrice + collectionPrice).currencyString)"
      self.costItemViewModel = LaundryItemInfoViewModel(type: .unavaliableCost(price: price), titleText: titleText, subTitleText: subTitleText)
    }
  }

}
