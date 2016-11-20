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
  case fetchCategoryClothes(categoryId: Int)
  case fetchClothesTreatments(itemId: Int)
  case createVerificationToken
  case verifyToken(token: String)
  case placeOrder(laundryId: Int)
  case fetchRatings(laundryId: Int)
  case fetchOrders

  var endpoint: String {
    switch self {
    case .fetchCities:
      return "cities.json"
    case .fetchCategories:
      return "categories.json"
    case .fetchCityLaundries(let cityId):
      return "cities/\(cityId)/laundries.json"
    case .fetchCategoryClothes(let categoryId):
      return "categories/\(categoryId)/items.json"
    case .fetchClothesTreatments(let itemId):
      return "items/\(itemId)/treatments.json"
    case .createVerificationToken:
      return "verification_tokens.json"
    case .verifyToken(let token):
      return "verification_tokens/\(token).json"
    case .placeOrder(let laundryId):
      return "laundries/\(laundryId)/orders.json"
    case .fetchRatings(let laundryId):
      return "laundries/\(laundryId)/ratings.json"
    case .fetchOrders:
      return "orders.json"

    }
  }
  
  var encoding: ParameterEncoding {
    switch self {
    case .placeOrder, .createVerificationToken, .verifyToken:
      return JSONEncoding.default
    default:
      return URLEncoding.default
    }
  }

  var successCode: Int {
    switch self {
    case .placeOrder, .createVerificationToken:
      return 201
    default:
      return 200
    }
  }
}

enum NetworkError: Error, CustomStringConvertible {
  case unprocessableData(response: Any)
  case unknown
  case serverUnavaliable
  case unexpectedResponseFormat

  var description: String {
    switch self {
    case .unprocessableData(let response):
      let json = JSON(response)
      print(response)
      guard let errorDictionary = json.dictionary else { return json.rawString() ?? "" }
      return parseErrorDictionary(errorDictionary)
    case .unknown:
      return "Неизвестная ошибка"
    case .serverUnavaliable:
      return "Ошибка на сервере"
    case .unexpectedResponseFormat:
      return "Неизвестный формат ответа сервера"
    }
  }
  
  func parseErrorDictionary(_ dictionary: [String: JSON]) -> String {
    var errorString = ""
    
    for (errorKey, errorValues) in dictionary {
      errorString += errorKey.localized("Errors")
      if let valuesArray = errorValues.array {
        errorString += ":"
        for value in valuesArray {
          errorString += " " + value.stringValue.localized("Errors")
        }
      }
      errorString += "\n"
    }
    
    return errorString
  }

}

class NetworkManager {

  var apiPrefix = "https://chisto-staging.herokuapp.com"

  func doRequest(method: HTTPMethod, _ path: APIPath, _ params: Parameters = [:]) -> Observable<Any> {
      return Observable.create { observer in
        let url = URL(string: self.apiPrefix + "/api/" + path.endpoint)!
        let request = Alamofire.request(url, method: method, parameters: params, encoding: path.encoding, headers: nil)
          .responseJSON { response in
            debugPrint(response)
            
            if let result = response.result.value {
              
              let statusCode = response.response?.statusCode
              if statusCode != path.successCode {
                observer.onError(self.getError(statusCode, response: result))
              }
              
              observer.onNext(result)
              observer.onCompleted()
            } else {
              observer.onError(NetworkError.unexpectedResponseFormat)
            }
            
        }

        return Disposables.create {
          request.cancel()

        }
      }
  }
  
  func getError(_ statusCode: Int?, response: Any) -> NetworkError {
    guard let statusCode = statusCode else { return .unknown }
    
    switch statusCode {
    case 422:
      return .unprocessableData(response: response)
    case 503, 500:
      return .serverUnavaliable
    default:
      return .unknown
    }
    
  }

}
