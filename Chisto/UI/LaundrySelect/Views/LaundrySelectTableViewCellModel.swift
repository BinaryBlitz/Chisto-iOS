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
  var price: String { get }
  var minimumOrderPrice: String { get }
  var disabledColor: UIColor { get }
}

class LaundrySelectTableViewCellModel: LaundrySelectTableViewCellModelType {

  let laundryTitle: String
  let laundryDescription: String
  var titleColor: UIColor = .black
  var descriptionColor: UIColor = .chsSlateGrey
  let rating: Float
  var tagBgColor: UIColor? = nil
  var tagName: String? = nil
  var price: String
  var minimumOrderPrice: String
  var disabledColor: UIColor = UIColor.chsCoolGrey
  var starRatingFullImage: UIImage = #imageLiteral(resourceName:"iconStarblueBigFull")
  var starRatingEmptyImage: UIImage = #imageLiteral(resourceName:"iconStarblueStroke")
  var tagIsHidden: Bool = false
  var isDisabled: Bool = true
  var logoUrl: URL?

  init(laundry: Laundry, type: LaundryType?) {
    var price = OrderManager.instance.price(laundry: laundry, includeCollection: false)
    let minimumOrderPrice = laundry.minimumOrderPrice
    let isDisabled = price < minimumOrderPrice
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

    if !isDisabled {
      let collectionPrice = OrderManager.instance.collectionPrice(laundry: laundry)
      price += collectionPrice
    }

    self.price = price.currencyString
    self.minimumOrderPrice = laundry.minimumOrderPrice.currencyString
  }
  

}
