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
  
  init(title: String) {
    self.title = title
  }
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
  
  var defaultCities = [
    City(title: "Москва"),
    City(title: "Нижний Новгород"),
    City(title: "Санкт-петербург"),
    ]
  
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
    
    for _ in 0...100 {
      defaultCities.append(City(title: "Город"))
    }
    
    cities = Variable<[City]>(defaultCities)
    
    self.sections = Observable.combineLatest(cities.asObservable(), searchString.asObservable(), location.asObservable(), resultSelector: { cities, searchString, location -> [CitySelectSectionModel] in
      print(location)
      if searchString.characters.count > 0 {
        let filteredCities = cities.filter {$0.title.lowercased().range(of: searchString.lowercased()) != nil}
        return [SectionModel(model: "", items: filteredCities)]
      } else {
        return [SectionModel(model: "", items: cities)]
      }
    }).asDriver(onErrorJustReturn: [])

    
    self.locationButtonDidTap.asObservable().flatMap({
      LocationManager.instance.locateDevice()
    }).bindTo(location).addDisposableTo(disposeBag)
    
    cancelSearchButtonDidTap.asObservable().map { event in
      return ""
      }.bindTo(self.searchString).addDisposableTo(disposeBag)
    
    // @TODO work with data
    
    self.presentOrderViewController = itemDidSelect.map{_ in Void()}.asDriver(onErrorDriveWith: .empty())
    
    self.presentCityNotFoundController = cityNotFoundButtonDidTap.asDriver(onErrorDriveWith: .empty())
    self.hideKeyboard = cancelSearchButtonDidTap.asDriver(onErrorDriveWith: .empty())
    self.showCancelButtonAnimated = searchBarDidBeginEditing.asDriver(onErrorDriveWith: .empty())
    self.hideCancelButtonAnimated = searchBarDidEndEditing.asDriver(onErrorDriveWith: .empty())
    
    
  }
  
  
}
