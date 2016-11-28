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
  case unknownApiPath
  case unknown
  
  var description: String {
    switch self {
    case .network(let error):
      return error.description
    case .responseConvertError:
      return "Response is not a valid JSON"
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

protocol DataManagerServiceType {
  func fetchCities() -> Observable<Void>
  func fetchCategories() -> Observable<Void>
  func fetchLaundries() -> Observable<Void>
  func fetchOrders() -> Observable<Void>
  func fetchCategoryClothes(category: Category) -> Observable<Void>
}

class DataManager {

  static let instance = DataManager()
  let disposeBag = DisposeBag()
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
  
  func getItems <ItemType>(type: ItemType.Type, apiPath: APIPath) -> Observable<[ItemType]> where ItemType: Mappable {
    return networkRequest(method: .get, apiPath)
      .flatMap { itemsJSON -> Observable<[ItemType]> in
        guard let items = Mapper<ItemType>().mapArray(JSONObject: itemsJSON) else {
          return Observable.error(DataError.responseConvertError)
        }
        return Observable.just(items)
    }

  }

  func fetchItems<ItemType>(type: ItemType.Type, apiPath: APIPath,
                  _ modifier: @escaping (ItemType) -> Void = {_ in }) -> Observable<Void> where ItemType: ServerObject {
    
    return getItems(type: type, apiPath: apiPath)
      .flatMap { items -> Observable<Void> in

        let realm = try! Realm()

        try realm.write {
          for item in items {
            modifier(item)
            realm.add(item, update: true)
          }
        }
                
        return Observable.empty()
      }
  }

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
    guard let verificationToken = ProfileManager.instance.userProfile.value.verificationToken else { return Observable.error(DataError.unknown) }

    return networkRequest(
        method: .patch,
        .verifyToken,
        ["code": code,
         "token": verificationToken]
      )
      .flatMap { response -> Observable<Void> in
        let json = JSON(object: response)
        ProfileManager.instance.updateProfile { profile in
          profile.apiToken = json["api_token"].string
        }
        return Observable.just()
      }
  }
  
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
    return networkRequest(method: .get, .showUser).map { json in
      guard let jsonMap = json as? [String: Any] else { throw DataError.responseConvertError }
      
      ProfileManager.instance.updateProfile { profile in
        let map = Map(mappingType: .fromJSON, JSON: jsonMap)
        profile.mapping(map: map)
        profile.isCreated = true
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
  
  init() {
    
    ProfileManager.instance.userProfile.asObservable()
      .filter { $0.city != nil }
      .map { $0.city! }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] _ in
        guard let disposeBag = self?.disposeBag else { return }
        self?.fetchLaundries().subscribe().addDisposableTo(disposeBag)
      }).addDisposableTo(disposeBag)
  }

}

extension DataManager: DataManagerServiceType {

  func fetchCities() -> Observable<Void> {
    return fetchItems(type: City.self, apiPath: .fetchCities)
  }

  func fetchCategories() -> Observable<Void> {
    return fetchItems(type: Category.self, apiPath: .fetchCategories)
  }

  func fetchCategoryClothes(category: Category) -> Observable<Void> {
    return fetchItems(
        type: Item.self, apiPath: .fetchCategoryClothes(categoryId: category.id)
      ) { item in
        item.category = category
      }
  }

  func fetchClothesTreatments(item: Item) -> Observable<Void> {
    return fetchItems(type: Treatment.self, apiPath: .fetchClothesTreatments(itemId: item.id)) { treatment in
      treatment.item = item
    }
  }

  func fetchLaundries() -> Observable<Void> {
    guard let cityId = ProfileManager.instance.userProfile.value.city?.id else { return Observable.error(DataError.unknown) }
    return fetchItems(type: Laundry.self, apiPath: .fetchCityLaundries(cityId: cityId))
  }
  
  func fetchRatings(laundry: Laundry) -> Observable<[Rating]> {
    return getItems(type: Rating.self, apiPath: .fetchRatings(laundryId: laundry.id))
  }
  
  func fetchOrders() -> Observable<Void> {
    return fetchItems(type: Order.self, apiPath: .fetchOrders)
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
  
  func fetchOrder(order: Order) -> Observable<Void> {
    return networkRequest(method: .get, .fetchOrder(orderId: order.id)).flatMap { result -> Observable<Void> in
      guard let order = Mapper<Order>().map(JSONObject: result) else { return Observable.error(DataError.responseConvertError) }
      let realm = try! Realm()
      
      try realm.write {
        realm.add(order, update: true)
      }
      
      return Observable.empty()
    }
  }

}
