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
      guard let errorDictionary = json.dictionary else { return json.stringValue }
      return parseErrorDictionary(errorDictionary)
    case .unknown:
      return "Неизвестная ошибка"
    case .serverUnavaliable:
      return "Сервер недоступен"
    case .unexpectedResponseFormat:
      return "Неизвестный формат ответа сервера"
    }
  }
  
  func parseErrorDictionary(_ dictionary: [String: JSON]) -> String {
    var errorString = ""
    
    for (errorKey, errorValue) in dictionary {
      errorString += errorKey.localized("Errors")
      if let valueString = errorValue.string {
        errorString += ": " + valueString.localized("Errors")
      }
      errorString += "\n"
    }
    
    return errorString
  }

}

class NetworkManager {

  var apiPrefix = "https://chisto-staging.herokuapp.com"

  func doRequest(method: HTTPMethod, _ path: APIPath, _ params: [String: String]? = nil, body: Parameters = [:], encoding: ParameterEncoding = URLEncoding.default) -> Observable<Any> {
      return Observable.create { observer in
        let url = URL(string: self.apiPrefix + "/api/" + path.endpoint)!
        let request = Alamofire.request(url.appendingQueryParams(parameters: params), method: method, parameters: body, encoding: encoding, headers: nil)
          .responseJSON { response in
            debugPrint(response)
            
            let statusCode = response.response?.statusCode
            if statusCode != path.successCode {
              observer.onError(self.getError(statusCode, response: response))
            }
            
            if let result = response.result.value {
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
    case 503:
      return .serverUnavaliable
    default:
      return .unknown
    }
    
  }

}
