//
//  DataManager.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import RxSwift
import RxCocoa
import RxRealm
import SwiftyJSON
import ObjectMapper

enum DataError: Error, CustomStringConvertible {
  case network(NetworkError)
  case responseConvertError
  case requestConvertError
  case unknownApiPath
  case applePayInvalidPayment
  case unknown(description: String)

  var description: String {
    switch self {
    case .network(let error):
      return error.description
    case .responseConvertError:
      return "Response is not a valid JSON"
    case .unknown(let description):
      return description
    case .unknownApiPath:
      return "API path for request was not set"
    case .applePayInvalidPayment:
      return "Invalid payment transaction"
    default:
      return ""
    }
  }

  var localizedDescription: String {
    return description
  }
}

/// A class that manages all the application data, stored in either Realm or user defaults. Uses NetworkManager to call the backend API
class DataManager {

  static let instance = DataManager()

  var termsOfServiceURL: URL {
    return URL(string: networkManager.baseURL + "/legal/terms-of-service.pdf")!
  }

  private var verificationToken: String? = nil
  private let networkManager = NetworkManager()

  /// Creates a new network request with pre-configured headers and params
  ///
  /// - Parameters:
  ///   - method: POST/GET/PUT etc.
  ///   - path: The endpoint to call
  ///   - params: JSON body or URL request body, depending on method
  /// - Returns: a new Observable, which receives API response as a single sequence element
  func networkRequest(method: HTTPMethod, _ path: APIPath, _ params: Parameters = [:]) -> Observable<Any> {
    var parameters = params
    if let token = ProfileManager.instance.userProfile.value.apiToken {
      parameters["api_token"] = token
    }
    let headers: HTTPHeaders = ["Accept": "application/json"]
    return networkManager.doRequest(method: method, path, parameters, headers)
      .map { data in JSON(data: data).rawValue }.catchError { error in
        guard let networkError = error as? NetworkError else { return Observable.error(error) }
        return Observable.error(DataError.network(networkError))
      }
  }

  /// Requests an array of items from server
  ///
  /// - Parameters:
  ///   - type: A class of returned objects. Must conform to the Mappable protocol
  ///   - apiPath: The endpoint to call
  ///   - params: JSON body or URL request body, depending on method
  /// - Returns: a new Observable, which receives API response as a single sequence element containing array of items
  func getItems<ItemType>(type: ItemType.Type, apiPath: APIPath, params: Parameters = [:]) -> Observable<[ItemType]> where ItemType: Mappable {
    return networkRequest(method: .get, apiPath, params)
      .flatMap { itemsJSON -> Observable<[ItemType]> in
        guard let items = Mapper<ItemType>().mapArray(JSONObject: itemsJSON) else {
          return Observable.error(DataError.responseConvertError)
        }
        return Observable.just(items)
      }

  }

  /// Requests an array of items from server and saves them to the Realm storage
  ///
  /// - Parameters:
  ///   - type: A class of returned objects. Must conform to the Mappable protocol
  ///   - apiPath: The endpoint to call
  ///   - params: JSON body or URL request body, depending on method
  ///   - modifier: A callback to modify every mapped object before saving it
  /// - Returns: a new Observable, which receives API response as a single sequence element containing array of items
  func fetchItems<ItemType>(type: ItemType.Type, apiPath: APIPath, params: Parameters = [:],
                            _ modifier: @escaping (ItemType) -> Void = { _ in }) -> Observable<[ItemType]> where ItemType: ServerObject {

    return getItems(type: type, apiPath: apiPath, params: params)
      .flatMap { items -> Observable<[ItemType]> in

        let realm = try! Realm()

        try realm.write {
          for item in items {
            modifier(item)
            realm.add(item, update: true)
          }
        }

        return Observable.just(items)
      }
  }
}

extension DataManager {

  func showLaundry(laundryId: Int) -> Observable<Laundry> {
    return networkRequest(method: .get, .showLaundry(laundryId: laundryId)).flatMap { result -> Observable<Laundry> in
      guard let laundry = Mapper<Laundry>().map(JSONObject: result) else { return Observable.error(DataError.responseConvertError) }
      let realm = try! Realm()

      try realm.write {
        realm.add(laundry, update: true)
      }

      return Observable.just(laundry)
    }
  }

  func showPromoCode(code: String) -> Observable<PromoCode?> {
    return networkRequest(method: .get, .showPromoCode(promoCode: code)).flatMap { result -> Observable<PromoCode?> in
      guard let promoCode = Mapper<PromoCode>().map(JSONObject: result) else { return Observable.error(DataError.responseConvertError) }
      return Observable.just(promoCode)
    }.catchErrorJustReturn(nil)
  }

  func subscribe(cityName: String, phone: String) -> Observable<Void> {
    let subscription = Subscription(phoneNumber: phone, content: cityName)
    return networkRequest(method: .post, .subscribe, ["subscription": subscription.toJSON()]).map { _ in }

  }

}
