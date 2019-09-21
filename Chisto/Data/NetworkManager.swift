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
      errorString += errorKey
      if let valuesArray = errorValues.array {
        errorString += " "
        for value in valuesArray {
          errorString += value.stringValue
        }
      }
      errorString += "\n"
    }

    return errorString
  }

}


/// A class that manages all the Chisto API calls
class NetworkManager {

  let baseURL = "https://chisto.xyz"
  
  /// Creates a new Observable, which receives API response as a single sequence element
  ///
  /// - Parameters:
  ///   - method: POST/GET/PUT etc.
  ///   - path: The endpoint to call
  ///   - params: JSON body or URL request body, depending on method
  ///   - headers: Headers of HTTP request
  /// - Returns: a new Observable, which receives API response as a single sequence element
  func doRequest(method: HTTPMethod, _ path: APIPath,
                 _ params: Parameters = [:],
                 _ headers: HTTPHeaders? = nil) -> Observable<Data> {

    let requestObservable: Observable<Data> = Observable.create { observer in
      guard let url = URL(string: self.baseURL + "/api/" + path.endpoint) else {
        observer.onError(DataError.requestConvertError)
        return Disposables.create()
      }

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
      },
      onCompleted: {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      },
      onSubscribe: {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
      },
      onDispose: {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
    )
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
