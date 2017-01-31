//
//  NetworkManager.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxDataSources
import SwiftyJSON

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
    }
  }

  var encoding: ParameterEncoding {
    switch self {
    case .createOrder, .createVerificationToken, .verifyToken, .createUser, .updateUser:
      return JSONEncoding.default
    default:
      return URLEncoding.default
    }
  }

  var successCode: Int {
    switch self {
    case .createOrder, .createVerificationToken, .createUser, .createRating, .subscribe:
      return 201
    default:
      return 200
    }
  }
}

enum NetworkError: Error, CustomStringConvertible {
  case unprocessableData(response: Data)
  case unknown
  case serverUnavaliable
  case unexpectedResponseFormat

  var description: String {
    switch self {
    case .unprocessableData(let response):
      let json = JSON(data: response)
      guard let errorDictionary = json.dictionary else { return json.rawString() ?? "" }
      return parseErrorDictionary(errorDictionary)
    case .unknown:
      return NSLocalizedString("unknownError", comment: "Network error")
    case .serverUnavaliable:
      return NSLocalizedString("serverError", comment: "Network error")
    case .unexpectedResponseFormat:
      return NSLocalizedString("unexpectedResponse", comment: "Network error")
    }
  }

  func parseErrorDictionary(_ dictionary: [String: JSON]) -> String {
    var errorString = ""

    for (errorKey, errorValues) in dictionary {
      errorString += NSLocalizedString(errorKey, tableName: "Errors", comment: "Server error")
      if let valuesArray = errorValues.array {
        errorString += " "
        for value in valuesArray {
          errorString += NSLocalizedString(value.stringValue, tableName: "Errors", comment: "Server error")
        }
      }
      errorString += "\n"
    }

    return errorString
  }

}

class NetworkManager {

  let baseURL = "https://chis.to"

  func doRequest(method: HTTPMethod, _ path: APIPath,
                 _ params: Parameters = [:],
                 _ headers: HTTPHeaders? = nil) -> Observable<Data> {

    let requestObservable: Observable<Data> = Observable.create { observer in
      let url = URL(string: self.baseURL + "/api/" + path.endpoint)!

      let request = Alamofire
        .request(url, method: method, parameters: params, encoding: path.encoding, headers: headers)
        .responseData { response in
          debugPrint(response)

          if let result = response.result.value {
            let json = JSON(data: response.result.value ?? Data())
            debugPrint(json)
            let statusCode = response.response?.statusCode
            if statusCode != path.successCode {
              observer.onError(self.getError(statusCode, response: result))
            }

            observer.onNext(result)
            observer.onCompleted()
          } else {
            if let error = response.result.error {
              observer.onError(error)
            } else {
              observer.onError(NetworkError.unexpectedResponseFormat)
            }
          }
      }

      return Disposables.create { request.cancel() }
    }

    return requestObservable.do(
      onError: { _ in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }, onCompleted: { _ in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }, onSubscribe: { _ in
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }, onDispose: { _ in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    })
  }

  func getError(_ statusCode: Int?, response: Data) -> NetworkError {
    guard let statusCode = statusCode else { return .unknown }

    switch statusCode {
    case 422: return .unprocessableData(response: response)
    case 503, 500: return .serverUnavaliable
    default: return .unknown
    }
  }
  
}
