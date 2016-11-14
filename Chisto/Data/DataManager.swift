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
}

protocol DataManagerServiceType {
  func fetchCities() -> Observable<Void>
  func fetchCategories() -> Observable<Void>
  func fetchLaundries() -> Observable<Void>
  func fetchCategoryClothes(categoryId: Int) -> Observable<Void>
}

class DataManager {
  static let instance = DataManager()
  var apiToken = "foobar"
  var verificationToken: String? = nil
  let networkManager = NetworkManager()
  
  func fetchItems<ItemType>(type: ItemType.Type, apiPath: APIPath) -> Observable<Void> where ItemType: ServerObjct {
    
    return networkManager.doRequest(method: .get, apiPath, ["api_token": apiToken])
      .catchError { error in
        if let error = error as? NetworkError {
          return Observable.error(DataError.network(error))
        } else {
          return Observable.error(DataError.unknown)
        }
      }
      .flatMap { itemsJSON -> Observable<Void> in
        guard let items = Mapper<ItemType>().mapArray(JSONObject: itemsJSON) else { return Observable.error(
          DataError.responseConvertError) }
        
        let realm = try! Realm()
        
        try realm.write {
          for item in items {
            realm.add(item, update: true)
          }
        }
        
        return Observable.empty()
    }

  }
  
  func createVerificationToken(phone: String) -> Observable<Void> {
    return networkManager.doRequest(method: .post, .createVerificationToken, ["phone_number": phone])
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
    return networkManager.doRequest(method: .patch, .verifyToken(token: verificationToken), ["code": code])
      .flatMap { response -> Observable<Void> in
        let json = JSON(object: response)
        self.apiToken = json["api_token"].stringValue
        return Observable.just()
    }
    
  }
}



extension DataManager: DataManagerServiceType {
  
  func fetchCities() -> Observable<Void> {
    return fetchItems(type: City.self, apiPath: .fetchCities)
  }
  
  func fetchCategories() -> Observable<Void> {
    return fetchItems(type: Category.self, apiPath: .fetchCategories)
  }
  
  func fetchCategoryClothes(categoryId: Int) -> Observable<Void> {
    return fetchItems(type: Item.self, apiPath: .fetchCategoryClothes(categoryId: categoryId))
  }
  
  func fetchClothesTreatments(itemId: Int) -> Observable<Void> {
    return fetchItems(type: Treatment.self, apiPath: .fetchClothesTreatments(itemId: itemId))
  }
  
  func fetchLaundries() -> Observable<Void> {
    guard let cityId = ProfileManager.instance.userProfile?.city?.id else { return Observable.error(DataError.unknown) }
    return fetchItems(type: Laundry.self, apiPath: .fetchCityLaundries(cityId: cityId))
  }
  
  func placeOrder(order: Order, laundry: Laundry) -> Observable<Int> {
    let orderJSON = order.toJSON()
    print(orderJSON)
    return networkManager.doRequest(method: .post, .placeOrder(laundryId: laundry.id),
                                    ["api_token": apiToken],
                                    body: ["order": orderJSON], encoding: JSONEncoding.default)
      .map { result in
        return JSON(result)["id"].intValue
    }
  }
}
