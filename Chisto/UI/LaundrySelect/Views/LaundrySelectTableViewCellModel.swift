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
  var starRatingFullImage: UIImage { get }
  var starRatingEmptyImage: UIImage { get }
  var titleColor: UIColor { get }
  var descriptionColor: UIColor { get }
  var logoUrl: URL? { get }
  var disabledColor: UIColor { get }
  var collectionItemViewModel: LaundryItemInfoViewModel { get }
  var deliveryItemViewModel: LaundryItemInfoViewModel { get }
  var priceItemViewModel: LaundryItemInfoViewModel { get }
}

class LaundrySelectTableViewCellModel: LaundrySelectTableViewCellModelType {

  let laundryTitle: String
  let laundryDescription: String
  var titleColor: UIColor = .black
  var descriptionColor: UIColor = .chsSlateGrey
  let rating: Float
  var tagBgColor: UIColor? = nil
  var tagName: String? = nil
  var disabledColor: UIColor = UIColor.chsCoolGrey
  var starRatingFullImage: UIImage = #imageLiteral(resourceName:"iconStarblueBigFull")
  var starRatingEmptyImage: UIImage = #imageLiteral(resourceName:"iconStarblueStroke")
  var tagIsHidden: Bool = false
  var isDisabled: Bool = true
  var logoUrl: URL?
  var collectionItemViewModel: LaundryItemInfoViewModel
  var deliveryItemViewModel: LaundryItemInfoViewModel
  var priceItemViewModel: LaundryItemInfoViewModel

  init(laundry: Laundry, type: LaundryType?) {
    var price = OrderManager.instance.price(laundry: laundry, includeCollection: false)
    let isDisabled = price < laundry.minimumOrderPrice
    self.isDisabled = isDisabled
    if isDisabled {
      self.starRatingFullImage = #imageLiteral(resourceName:"iconStarblueGrayFull")
      self.starRatingEmptyImage = #imageLiteral(resourceName:"iconStarblueGrayStroke")
      self.titleColor = disabledColor
      self.descriptionColor = disabledColor
    }

    self.laundryTitle = laundry.name
    self.laundryDescription = laundry.descriptionText
    self.rating = laundry.rating
    self.logoUrl = URL(string: laundry.logoUrl)

    let collectionDateString = laundry.collectionFrom.shortDate

    self.collectionItemViewModel = LaundryItemInfoViewModel(
      type: .collection,
      titleText: collectionDateString,
      subTitleText: laundry.collectionTimeInterval,
      isDisabled: isDisabled
    )

    let deliveryDateString = laundry.deliveryFrom.shortDate

    self.deliveryItemViewModel = LaundryItemInfoViewModel(
      type: .delivery,
      titleText: deliveryDateString,
      subTitleText: laundry.deliveryTimeInterval,
      isDisabled: isDisabled
    )

    if !isDisabled {
      let collectionPrice = OrderManager.instance.collectionPrice(laundry: laundry)
      price += collectionPrice
    }

    let priceString = price.currencyString

    if !isDisabled {
      self.priceItemViewModel = LaundryItemInfoViewModel(type: .price, titleText: priceString)
    } else {
      let titleText = NSLocalizedString("minimumOrderPrice", comment: "List of offers")
      let subTitleText = "\((laundry.minimumOrderPrice).currencyString)"

      self.priceItemViewModel = LaundryItemInfoViewModel(
        type: .unavaliableprice(price: price),
        titleText: titleText,
        subTitleText: subTitleText
      )
    }
  }

}
