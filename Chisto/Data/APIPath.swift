//
//  APIPath.swift
//  Chisto
//
//  Created by Алексей on 16.03.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import Alamofire

enum APIPath {
  case fetchCities
  case fetchCategories
  case fetchCityLaundries(cityId: Int)
  case showLaundry(laundryId: Int)
  case fetchCategoryClothes(categoryId: Int)
  case fetchClothesTreatments(itemId: Int)
  case createVerificationToken
  case verifyToken
  case createOrder(laundryId: Int)
  case fetchRatings(laundryId: Int)
  case fetchOrders
  case fetchOrder(orderId: Int)
  case createUser
  case showUser
  case updateUser
  case createRating(laundryId: Int)
  case subscribe
  case showPromoCode(promoCode: String)
  case fetchItems
  case updateRating(ratingId: Int)
  case sendPaymentToken(orderId: Int)

  var endpoint: String {
    switch self {
    case .fetchCities:
      return "cities"
    case .fetchCategories:
      return "categories"
    case .fetchCityLaundries(let cityId):
      return "cities/\(cityId)/laundries"
    case .fetchCategoryClothes(let categoryId):
      return "categories/\(categoryId)/items"
    case .fetchClothesTreatments(let itemId):
      return "items/\(itemId)/treatments"
    case .createVerificationToken, .verifyToken:
      return "verification_token"
    case .createOrder(let laundryId):
      return "laundries/\(laundryId)/orders"
    case .showLaundry(let laundryId):
      return "laundries/\(laundryId)"
    case .fetchRatings(let laundryId):
      return "laundries/\(laundryId)/ratings"
    case .fetchOrders:
      return "orders"
    case .fetchOrder(let orderId):
      return "orders/\(orderId)"
    case .createRating(let laundryId):
      return "laundries/\(laundryId)/ratings"
    case .createUser, .showUser, .updateUser:
      return "user"
    case .subscribe:
      return "subscriptions"
    case .showPromoCode(let promoCode):
      return "promo_codes/\(promoCode)"
    case .fetchItems:
      return "items"
    case .updateRating(let ratingId):
      return "ratings/\(ratingId)"
    case .sendPaymentToken(let orderId):
      return "orders/\(orderId)/payment_token"
    }
  }

  var encoding: ParameterEncoding {
    switch self {
    case .createOrder, .createVerificationToken, .verifyToken, .createUser, .updateUser, .sendPaymentToken:
      return JSONEncoding.default
    default:
      return URLEncoding.default
    }
  }

  var successCode: Int {
    switch self {
    case .createOrder, .createVerificationToken, .createUser, .createRating, .subscribe, .sendPaymentToken:
      return 201
    default:
      return 200
    }
  }
}
