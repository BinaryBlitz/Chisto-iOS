//
//  DataManager+FetchItemsManagerType.swift
//  Chisto
//
//  Created by Алексей on 16.03.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import RxSwift
import RxCocoa
import RxRealm
import SwiftyJSON
import ObjectMapper

protocol FetchItemsManagerType {
  func fetchCities() -> Observable<Void>
  func fetchCategories() -> Observable<Void>
  func fetchOrders() -> Observable<Void>
  func fetchCategoryClothes(category: Category) -> Observable<Void>
  func fetchClothesTreatments(item: Item) -> Observable<Void>
  func fetchRatings(laundry: Laundry) -> Observable<[Rating]>
  func fetchClothes() -> Observable<Void>
  func getLaundries() -> Observable<[Laundry]>
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

}
