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
  private var apiToken = "foobar"
  private var verificationToken: String? = nil
  private let networkManager = NetworkManager()
  
  func networkRequest(method: HTTPMethod, _ path: APIPath, _ params: Parameters = [:]) -> Observable<Any> {
    var parameters = params
    let token = apiToken
    parameters["api_token"] = token
    let headers: HTTPHeaders = ["Accept": "application/json"]
    return networkManager.doRequest(method: method, path, parameters, headers)
      .catchError { error in
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
        // TODO: work with real SMS codes
        // self.verificationToken = json["token"].stringValue
        self.verificationToken = "yB9XcdWzvgAUPHzWt4XuySRR"
        ProfileManager.instance.updateProfile { profile in
          profile.phone = json["phone_number"].stringValue
        }
        return Observable.just()
      }
  }

  func verifyToken(code: String) -> Observable<Void> {
    guard let verificationToken = self.verificationToken else { return Observable.error(DataError.unknown) }

    return networkManager.doRequest(
        method: .patch,
        .verifyToken(token: verificationToken),
        ["code": code]
      )
      .flatMap { response -> Observable<Void> in
        // TODO: use real token
        //let json = JSON(object: response)
        ProfileManager.instance.updateProfile { profile in
          // profile.apiToken = json["api_token"].stringValue
          profile.apiToken = "foobar"
        }
        return Observable.just()
      }
  }
  
  init() {
    
    // 
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

  func placeOrder(order: RequestOrder, laundry: Laundry) -> Observable<Order> {
    let orderJSON = order.toJSON()
    
    return networkRequest(
        method: .post,
        .placeOrder(laundryId: laundry.id),
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
