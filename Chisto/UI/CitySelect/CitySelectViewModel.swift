//
//  CitySelectViewModel.swift
//  Chisto
//
//  Created by Алексей on 11.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import UIKit
import CoreLocation

struct City {
  let index = 0
  var title = ""
}

typealias CitySelectSectionModel = SectionModel<String, City>

protocol CitySelectViewModelType {
  
  // Input
  var locationButtonDidTap: PublishSubject<Void> { get }
  var cancelSearchButtonDidTap: PublishSubject<Void> { get }
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var cityNotFoundButtonDidTap: PublishSubject<Void> { get }
  var searchString: ReplaySubject<String> { get }
  var searchBarDidEndEditing: PublishSubject<Void> { get }
  var searchBarDidBeginEditing: PublishSubject<Void> { get }
  
  // Output
  var navigationBarTitle: String { get }
  var sections: Driver<[CitySelectSectionModel]> { get }
  var presentCityNotFoundController: Driver<Void> { get }
  var presentOrderViewController: Driver<Void> { get }
  var hideKeyboard: Driver<Void> { get }
  var showCancelButtonAnimated: Driver<Void> { get }
  var hideCancelButtonAnimated: Driver<Void> { get }
  
}

class CitySelectViewModel: CitySelectViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  var locationButtonDidTap = PublishSubject<Void>()
  var cancelSearchButtonDidTap = PublishSubject<Void>()
  var itemDidSelect = PublishSubject<IndexPath>()
  var cityNotFoundButtonDidTap = PublishSubject<Void>()
  var searchString = ReplaySubject<String>.create(bufferSize: 1)
  var searchBarDidEndEditing = PublishSubject<Void>()
  var searchBarDidBeginEditing = PublishSubject<Void>()
  
  // Output
  var navigationBarTitle = "Выбор города"
  var sections: Driver<[CitySelectSectionModel]>
  var presentCityNotFoundController: Driver<Void>
  var presentOrderViewController: Driver<Void>
  var hideKeyboard: Driver<Void>
  var showCancelButtonAnimated: Driver<Void>
  var hideCancelButtonAnimated: Driver<Void>
  
  // Data
  var cities: Variable<[City]>
  var location = Variable<CLLocationCoordinate2D?>(nil)
  
  init() {
    let defaultCities = ["Москва", "Санкт-Петербург"] + [String](repeating: "Город", count: 25)
    cities = Variable<[City]>(defaultCities.map { City(title: $0) })
    
    self.sections = Observable.combineLatest(cities.asObservable(), searchString.asObservable(), location.asObservable()) { cities, searchString, location -> [CitySelectSectionModel] in
      var filteredCities = cities
      if searchString.characters.count > 0 {
        filteredCities = cities.filter { $0.title.lowercased().range(of: searchString.lowercased()) != nil }
      }
      return [CitySelectSectionModel(model: "", items: filteredCities)]
    }.asDriver(onErrorJustReturn: [])

    
    locationButtonDidTap.asObservable()
      .flatMap {
        LocationManager.instance.locateDevice()
      }
      .bindTo(location)
      .addDisposableTo(disposeBag)
    
    cancelSearchButtonDidTap.asObservable()
      .map { event in
        return ""
      }
      .bindTo(searchString)
      .addDisposableTo(disposeBag)
    
    // TODO: work with data
    self.presentOrderViewController = itemDidSelect.map { indexPath in
      UserDefaults.standard.set(indexPath.row, forKey: "userCity")
      return Void()
    }.asDriver(onErrorDriveWith: .empty())
    
    self.presentCityNotFoundController = cityNotFoundButtonDidTap.asDriver(onErrorDriveWith: .empty())
    self.hideKeyboard = cancelSearchButtonDidTap.asDriver(onErrorDriveWith: .empty())
    self.showCancelButtonAnimated = searchBarDidBeginEditing.asDriver(onErrorDriveWith: .empty())
    self.hideCancelButtonAnimated = searchBarDidEndEditing.asDriver(onErrorDriveWith: .empty())
  }

}
