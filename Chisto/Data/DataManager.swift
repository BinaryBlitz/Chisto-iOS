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
    default:
      return ""
    }
  }

  var localizedDescription: String {
    return description
  }
}

protocol FetchItemsManagerType {
  func fetchCities() -> Observable<Void>
  func fetchCategories() -> Observable<Void>
  func fetchOrders() -> Observable<Void>
  func fetchCategoryClothes(category: Category) -> Observable<Void>
}

protocol TokenManagerType {
  func createVerificationToken(phone: String) -> Observable<Void>
  func verifyToken(code: String) -> Observable<Void>
}

protocol UserManagerType {
  func updateUser() -> Observable<Void>
  func showUser() -> Observable<Void>
  func createUser() -> Observable<Void>
}

class DataManager {

  static let instance = DataManager()

  var termsOfServiceURL: URL {
    return URL(string: networkManager.baseURL + "/legal/terms-of-service.pdf")!
  }

  private var verificationToken: String? = nil
  private let networkManager = NetworkManager()

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

  func getItems<ItemType>(type: ItemType.Type, apiPath: APIPath, params: Parameters = [:]) -> Observable<[ItemType]> where ItemType: Mappable {
    return networkRequest(method: .get, apiPath, params)
      .flatMap { itemsJSON -> Observable<[ItemType]> in
        guard let items = Mapper<ItemType>().mapArray(JSONObject: itemsJSON) else {
          return Observable.error(DataError.responseConvertError)
        }
        return Observable.just(items)
      }

  }

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

extension DataManager: UserManagerType {
  func createUser() -> Observable<Void> {
    let profile = ProfileManager.instance.userProfile.value
    let realm = try! Realm()
    var jsonProfile: [String: Any] = [:]
    try? realm.write {
      jsonProfile["user"] = profile.toJSON()
    }
    return networkRequest(method: .post, .createUser, jsonProfile).map { json in
      guard let jsonMap = json as? [String: Any] else { throw DataError.responseConvertError }

      ProfileManager.instance.updateProfile { profile in
        let map = Map(mappingType: .fromJSON, JSON: jsonMap)
        profile.mapping(map: map)
        profile.isCreated = true
      }
    }
  }

  func showUser() -> Observable<Void> {
    guard ProfileManager.instance.userProfile.value.apiToken != nil else { return Observable.just(()) }
    return networkRequest(method: .get, .showUser).map { json in
      guard let jsonMap = json as? [String: Any] else { throw DataError.responseConvertError }
      let realm = try! Realm()

      let order = Mapper<Order>().map(JSONObject: jsonMap["order"])
      if let order = order {
        try! realm.write { realm.add(order, update: true) }
      }

      ProfileManager.instance.updateProfile { profile in
        let map = Map(mappingType: .fromJSON, JSON: jsonMap)
        profile.mapping(map: map)
        profile.isCreated = true
        profile.order = order
      }
    }
  }

  func updateUser() -> Observable<Void> {
    let profile = ProfileManager.instance.userProfile.value
    let realm = try! Realm()
    var jsonProfile: [String: Any] = [:]
    try? realm.write {
      jsonProfile["user"] = profile.toJSON()
    }
    return networkRequest(method: .patch, .updateUser, jsonProfile).map { _ in }
  }
}

extension DataManager: TokenManagerType {
  func createVerificationToken(phone: String) -> Observable<Void> {
    return networkRequest(method: .post, .createVerificationToken, ["phone_number": phone])
      .flatMap { response -> Observable<Void> in
        let json = JSON(object: response)
        let verificationToken = json["token"].string
        ProfileManager.instance.updateProfile { profile in
          profile.verificationToken = verificationToken
          profile.phone = json["phone_number"].stringValue
        }
        return Observable.just()
      }
  }

  func verifyToken(code: String) -> Observable<Void> {
    guard let verificationToken = ProfileManager.instance.userProfile.value.verificationToken else { return Observable.error(DataError.unknown(description: "")) }

    return networkRequest(
      method: .patch,
      .verifyToken,
      ["code": code,
       "token": verificationToken]
    )
      .flatMap { response -> Observable<Void> in
        let json = JSON(object: response)
        print(json)
        ProfileManager.instance.updateProfile { profile in
          profile.apiToken = json["api_token"].string
          profile.isVerified = true
        }
        return Observable.just()
      }
  }
}

extension DataManager: FetchItemsManagerType {

  func fetchCities() -> Observable<Void> {
    return fetchItems(type: City.self, apiPath: .fetchCities).map { newCities in
      let realm = try! Realm()
      let cities = Set(realm.objects(City.self).toArray())
      for city in cities.subtracting(Set(newCities)) {
        try realm.write {
          city.isDeleted = true
        }
      }
    }
  }

  func fetchCategories() -> Observable<Void> {
    return fetchItems(type: Category.self, apiPath: .fetchCategories).map { newCategories in
      let realm = try! Realm()
      let categories = Set(realm.objects(Category.self).toArray())
      for category in categories.subtracting(Set(newCategories)) {
        try realm.write {
          category.isDeleted = true
        }
      }
    }
  }

  func fetchClothes() -> Observable<Void> {
    return fetchItems(type: Item.self, apiPath: .fetchItems).map { newItems in
      let realm = try! Realm()
      let items = Set(realm.objects(Item.self).toArray())
      for item in items.subtracting(Set(newItems)) {
        try realm.write {
          item.isDeleted = true
        }
      }
    }
  }

  func fetchCategoryClothes(category: Category) -> Observable<Void> {
    return fetchItems(
      type: Item.self, apiPath: .fetchCategoryClothes(categoryId: category.id)
    ) { item in
      item.category = category
    }.map { newItems in
      let realm = try! Realm()
      let clothes = Set(realm.objects(Item.self)
        .filter { $0.category == category })

      for item in clothes.subtracting(Set(newItems)) {
        try realm.write {
          item.isDeleted = true
        }
      }
    }
  }

  func fetchClothesTreatments(item: Item) -> Observable<Void> {
    return fetchItems(type: Treatment.self, apiPath: .fetchClothesTreatments(itemId: item.id)) { treatment in
      treatment.item = item
    }.map { newTreatments in
      let realm = try! Realm()
      let treatments = Set(realm.objects(Treatment.self)
        .filter { $0.item == item })

      for treatment in treatments.subtracting(Set(newTreatments)) {
        try realm.write {
          treatment.isDeleted = true
        }
      }
    }
  }

  func getLaundries() -> Observable<[Laundry]> {
    guard let city = ProfileManager.instance.userProfile.value.city, let items = try? OrderManager.instance.currentOrderItems.value() else { return Observable.error(DataError.unknown(description: "")) }
    var params: [String : Any] = [:]
    if !items.filter({ $0.clothesItem.longTreatment }).isEmpty {
      params["long_treatment"] = 1
    }
    return fetchItems(type: Laundry.self, apiPath: .fetchCityLaundries(cityId: city.id), params: params) { laundry in
      laundry.city = city
    }.map { newLaundries in
      let realm = try! Realm()
      let laundries = Set(realm.objects(Laundry.self).filter { $0.city == city })
      for laundry in laundries.subtracting(Set(newLaundries)) {
        try realm.write {
          laundry.isDeleted = true
        }
      }
      return newLaundries
    }
  }

  func fetchRatings(laundry: Laundry) -> Observable<[Rating]> {
    return getItems(type: Rating.self, apiPath: .fetchRatings(laundryId: laundry.id))
  }

  func fetchOrders() -> Observable<Void> {
    return fetchItems(type: Order.self, apiPath: .fetchOrders).map { newOrders in
      let realm = try! Realm()
      let orders = Set(realm.objects(Order.self).toArray())
      for order in orders.subtracting(Set(newOrders)) {
        try realm.write {
          order.isDeleted = true
        }
      }

    }
  }

  func createOrder(order: RequestOrder, laundry: Laundry) -> Observable<Order> {
    let orderJSON = order.toJSON()

    return networkRequest(
      method: .post,
      .createOrder(laundryId: laundry.id),
      ["order": orderJSON]
    )
      .flatMap { result -> Observable<Order> in
        guard let order = Mapper<Order>().map(JSONObject: result) else { return Observable.error(DataError.responseConvertError) }
        let realm = try! Realm()

        try realm.write {
          realm.add(order, update: true)
        }

        return Observable.just(order)
      }
  }

  func getOrderInfo(orderId: Int) -> Observable<Order> {
    return networkRequest(method: .get, .fetchOrder(orderId: orderId)).flatMap { result -> Observable<Order> in
      guard let order = Mapper<Order>().map(JSONObject: result) else { return Observable.error(DataError.responseConvertError) }
      let realm = try! Realm()

      try realm.write {
        realm.add(order, update: true)
      }

      return Observable.just(order)
    }
  }

  func sendNotificationToken(tokenString: String) -> Observable<Void> {
    let userData: Dictionary = ["user": ["device_token": tokenString, "platform": "ios"]]

    return networkRequest(method: .patch, .updateUser, userData).map { _ in }
  }

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

  func createRating(laundryId: Int, rating: Rating) -> Observable<Void> {
    let json = rating.toJSON()

    return networkRequest(method: .post, .createRating(laundryId: laundryId), ["rating": json]).map { _ in }
  }

  func subscribe(cityName: String, phone: String) -> Observable<Void> {
    let subscription = Subscription(phoneNumber: phone, content: cityName)
    return networkRequest(method: .post, .subscribe, ["subscription": subscription.toJSON()]).map { _ in }

  }

}
