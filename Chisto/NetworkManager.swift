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
      return "verification_tokens.jsn"
    case .verifyToken(let token):
      return "verification_tokens/\(token).json"
    case .placeOrder(let laundryId):
      return "laundries/\(laundryId)/orders.json"
    }
    
    
  }
  
  var successCode: Int {
    switch self {
    case .placeOrder:
      return 201
    case .createVerificationToken:
      return 201
    default:
      return 200
    }
  }
}

enum NetworkError: Error, CustomStringConvertible {
  case unknown(description: String)
  case serverUnavaliable
  
  var description: String {
    switch self {
    case .unknown(let description):
      return description
    case .serverUnavaliable:
      return "Сервер недоступен"
    }
  }
  
}

class NetworkManager {
  
  var apiPrefix = "https://chisto-staging.herokuapp.com"
  
  func doRequest(method: HTTPMethod, _ path: APIPath, _ params: [String: String]? = nil, body: Parameters = [:], encoding: ParameterEncoding = URLEncoding.default) -> Observable<Any> {
      return Observable.create { observer in
        let url = URL(string: self.apiPrefix + "/api/" + path.endpoint)!
        let req = Alamofire.request(url.appendingQueryParams(parameters: params), method: method, parameters: body, encoding: encoding, headers: nil)
          .responseJSON { response in
            debugPrint(response)
            if response.response?.statusCode != path.successCode {
              observer.onError(NetworkError.unknown(description: "Ошибка сервера"))
            }
            if let result = response.result.value {
              debugPrint(result)
              observer.onNext(result)
              observer.onCompleted()
            } else {
              observer.onError(NetworkError.unknown(description: "Unexpected response format"))
            }
        }
        
        return Disposables.create {
          req.cancel()
          
        }
      }
  }

}
