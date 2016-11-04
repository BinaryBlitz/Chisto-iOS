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
  case FetchCities
  case FetchCategories
  case FetchLaundries
  
  var endpoint: String {
    switch self {
    case .FetchCities:
      return "cities.json"
    case .FetchCategories:
      return "categories.json"
    case .FetchLaundries:
      return "laundries.json"
    }
  }
  
  var successCode: Int {
    return 200
  }
}

enum NetworkError: Error, CustomStringConvertible {
  case Unknown(description: String)
  case ServerUnavaliable
  
  var description: String {
    switch self {
    case .Unknown(let description):
      return description
    case .ServerUnavaliable:
      return "Сервер недоступен"
    }
  }
  
}

class NetworkManager {
  
  var apiPrefix = "https://chisto-staging.herokuapp.com"
  
  func doRequest(method: HTTPMethod, _ path: APIPath, _ params: [String: Any]? = [:]) -> Observable<Any> {
      return Observable.create { observer in
        let req = Alamofire.request(self.apiPrefix + "/api/" + path.endpoint, method: method, parameters: params, encoding: URLEncoding.default)
          .responseJSON { response in
            debugPrint(response)
            if response.response?.statusCode != path.successCode {
              observer.onError(NetworkError.Unknown(description: "Ошибка сервера"))
            }
            if let result = response.result.value {
              debugPrint(result)
              observer.onNext(result)
              observer.onCompleted()
            } else {
              observer.onError(NetworkError.Unknown(description: "Unexpected response format"))
            }
        }
        
        return Disposables.create {
          req.cancel()
          
        }
      }
  }

}
