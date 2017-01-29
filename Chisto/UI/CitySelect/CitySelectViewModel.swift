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
import RealmSwift

typealias CitySelectSectionModel = SectionModel<String, City>

protocol CitySelectViewModelType {

  // Input
  var locationButtonDidTap: PublishSubject<Void> { get }
  var cancelSearchButtonDidTap: PublishSubject<Void> { get }
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var cityNotFoundButtonDidTap: PublishSubject<Void> { get }
  var searchString: PublishSubject<String?> { get }
  var searchBarDidEndEditing: PublishSubject<Void> { get }
  var searchBarDidBeginEditing: PublishSubject<Void> { get }

  // Output
  var navigationBarTitle: String { get }
  var sections: Driver<[CitySelectSectionModel]> { get }
  var presentCityNotFoundController: Driver<Void> { get }
  var hideKeyboard: Driver<Void> { get }
  var showCancelButtonAnimated: Driver<Void> { get }
  var hideCancelButtonAnimated: Driver<Void> { get }

}

class CitySelectViewModel: CitySelectViewModelType {
  let disposeBag = DisposeBag()

  // Input
  let locationButtonDidTap = PublishSubject<Void>()
  let cancelSearchButtonDidTap = PublishSubject<Void>()
  let itemDidSelect = PublishSubject<IndexPath>()
  let cityNotFoundButtonDidTap = PublishSubject<Void>()
  let searchString = PublishSubject<String?>()
  let searchBarDidEndEditing = PublishSubject<Void>()
  let searchBarDidBeginEditing = PublishSubject<Void>()

  // Output
  let navigationBarTitle = NSLocalizedString("chooseCity", comment: "City select screen title")
  let sections: Driver<[CitySelectSectionModel]>
  let presentCityNotFoundController: Driver<Void>
  let hideKeyboard: Driver<Void>
  let showCancelButtonAnimated: Driver<Void>
  let hideCancelButtonAnimated: Driver<Void>
  let presentErrorAlert: PublishSubject<Error>

  // Data
  var cities: Variable<[City]>
  let cityClosedToUser: Variable<City?>
  var location = Variable<CLLocationCoordinate2D?>(nil)
  var selectedCity = PublishSubject<City>()

  init() {
    // Data
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert
    
    DataManager.instance.fetchCities().subscribe(onError: { error in
      presentErrorAlert.onNext(error)
    }).addDisposableTo(disposeBag)

    let realm = RealmManager.instance.uiRealm
    
    let cities = Variable<[City]>([])
    Observable.from(realm.objects(City.self).filter("isDeleted == %@", false))
      .map { Array($0) }
      .bindTo(cities)
      .addDisposableTo(disposeBag)
    
    let cityClosedToUser = Variable<City?>(nil)
    self.cityClosedToUser = cityClosedToUser

    self.cities = cities

    // Table View
    self.sections = Observable.combineLatest(cities.asObservable(), searchString.asObservable(), location.asObservable()) { cities, searchString, location -> [CitySelectSectionModel] in
      var filteredCities = cities
      if let searchString = searchString, searchString.characters.count > 0 {
        filteredCities = cities
          .filter { $0.name.lowercased().range(of: searchString.lowercased()) != nil }
      }
      
      filteredCities.sort { $0.distanceTo(location) < $1.distanceTo(location) }
      
      if location != nil {
        cityClosedToUser.value = filteredCities.first
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

    self.presentCityNotFoundController = cityNotFoundButtonDidTap.asDriver(onErrorDriveWith: .empty())
    self.hideKeyboard = cancelSearchButtonDidTap.asDriver(onErrorDriveWith: .empty())
    self.showCancelButtonAnimated = searchBarDidBeginEditing.asDriver(onErrorDriveWith: .empty())
    self.hideCancelButtonAnimated = searchBarDidEndEditing.asDriver(onErrorDriveWith: .empty())

    itemDidSelect.asObservable().subscribe(onNext: {[weak self] indexPath in
      ProfileManager.instance.updateProfile { profile in
        profile.city = cities.value[indexPath.row]
      }
      self?.selectedCity.onNext(cities.value[indexPath.row])
    }).addDisposableTo(disposeBag)
  }

}
