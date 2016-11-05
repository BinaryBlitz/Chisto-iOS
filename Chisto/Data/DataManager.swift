//
//  DataManager.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//
import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
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
  let apiToken = "foobar"
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

}

extension DataManager: DataManagerServiceType {
  var cityId: Int? {
    return UserDefaults.standard.value(forKey: "userCity") as? Int
  }
  
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
    guard let cityId = self.cityId else { return Observable.error(DataError.unknown) }
    return fetchItems(type: Laundry.self, apiPath: .fetchCityLaundries(cityId: cityId))
  }
}
