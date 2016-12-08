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

  let disposeBag = DisposeBag()

  let locationButtonDidTap = PublishSubject<Void>()
  var cityLocation = CLLocationCoordinate2D()
  let markerLocation = PublishSubject<CLLocationCoordinate2D>()

  let cityZoom: Float = 10
  let markerZoom: Float = 17 

  let saveButtonDidTap = PublishSubject<Void>()
  let popViewContoller: Driver<Void>
  let streetNumber:  PublishSubject<String>
  let streetName: PublishSubject<String>
  let searchBarText = Variable<String?>(nil)
  
  let adress: Variable<Adress?>

  init() {

    LocationManager.instance.locateDevice(requestPermission: false)
      .filter { $0 != nil }
      .map { $0! }.bindTo(markerLocation).addDisposableTo(disposeBag)

    let streetNumber =  PublishSubject<String>()
    self.streetNumber = streetNumber

    let streetName = PublishSubject<String>()
    self.streetName = streetName
    
    let adress = Variable<Adress?>(nil)
    self.adress = adress

    self.popViewContoller = saveButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    saveButtonDidTap.asObservable().subscribe(onNext: { coordinate in
      guard let adress = adress.value else { return }
      
      if let number = adress.streetNumber {
        streetNumber.onNext(number)
      }
      
      if let name = adress.streetName {
        streetName.onNext(name)
      }

    }).addDisposableTo(disposeBag)

    guard let city = ProfileManager.instance.userProfile.value.city else { return }

    self.cityLocation = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)

    locationButtonDidTap.asObservable()
      .flatMap {
        LocationManager.instance.locateDevice()
      }
      .filter { $0 != nil }
      .map { return $0! }
      .bindTo(markerLocation)
      .addDisposableTo(disposeBag)
    
    markerLocation.asObservable().flatMap { coordinate -> Driver<Adress?> in
      ReverseGeocoder.getAdress(coordinate: coordinate).asDriver(onErrorJustReturn: nil)
    }.bindTo(adress).addDisposableTo(disposeBag)
    
    adress.asObservable().map { adress -> String in
      guard let number = adress?.streetNumber else { return "" }
      guard let streetName = adress?.streetName else { return "" }
      
      return "\(streetName), \(number)"
    }.bindTo(searchBarText).addDisposableTo(disposeBag)
    
  }
  
  
}
