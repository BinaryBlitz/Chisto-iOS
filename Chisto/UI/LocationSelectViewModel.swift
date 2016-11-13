//
//  LocationSelectViewModel.swift
//  Chisto
//
//  Created by Алексей on 12.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import RxSwift
import RxCocoa
import GoogleMaps

protocol LocationSelectViewModelType {
  var locationButtonDidTap: PublishSubject<Void> { get }
  var disposeBag: DisposeBag  { get }
  var cityLocation: CLLocationCoordinate2D  { get }
  var markerLocation: PublishSubject<CLLocationCoordinate2D>  { get }
  var cityZoom: Float { get }
  var markerZoom: Float { get }
}

class LocationSelectViewModel: LocationSelectViewModelType {
  let locationButtonDidTap = PublishSubject<Void>()
  let disposeBag = DisposeBag()
  var cityLocation = CLLocationCoordinate2D()
  let markerLocation = PublishSubject<CLLocationCoordinate2D>()
  let cityZoom: Float = 10
  let markerZoom: Float = 20
  let saveButtonDidDap = PublishSubject<Void>()
  let didPickCoordinate = PublishSubject<CLLocationCoordinate2D>()
  let popViewContoller: Driver<Void>
  let streetNumber:  PublishSubject<String>
  let streetName: PublishSubject<String>
  
  init() {
    let streetNumber =  PublishSubject<String>()
    self.streetNumber = streetNumber
    
    let streetName = PublishSubject<String>()
    self.streetName = streetName
    
    self.popViewContoller = didPickCoordinate.asObservable().flatMap { coordinate in
      return GeocodingManager.getAdress(coordinate: coordinate).map { adress in
        if let number = adress?.streetNumber {
          streetNumber.onNext(number)
        }
        
        if let name = adress?.streetName {
          streetName.onNext(name)
        }
        
        return Void()
      }
      
    }.asDriver(onErrorDriveWith: .empty())

    guard let city = ProfileManager.instance.userProfile?.city else { return }

    self.cityLocation = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)
    
    locationButtonDidTap.asObservable()
      .flatMap {
        LocationManager.instance.locateDevice()
      }
      .filter { $0 != nil }
      .map { return $0! }
      .bindTo(markerLocation)
      .addDisposableTo(disposeBag)
    
  }
}
