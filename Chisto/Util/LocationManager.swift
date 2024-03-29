//
//  LocationManager.swift
//  Chisto
//
//  Created by Алексей on 12.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation

class LocationManager {

  static let instance = LocationManager()
  private let locationManager = CLLocationManager()

  private (set) var autorized: Driver<Bool>
  private (set) var location: Observable<CLLocationCoordinate2D?>

  private init() {
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.desiredAccuracy = kCLLocationAccuracyBest

    autorized = locationManager.rx
      .didChangeAuthorizationStatus
      .startWith(CLLocationManager.authorizationStatus())
      .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
      .map { $0 == .authorizedAlways || $0 == .authorizedWhenInUse }

    location = locationManager.rx
      .didUpdateLocations
      .filter { $0.count > 0 }
      .map { $0.last!.coordinate }
  }

  func locateDevice(requestPermission: Bool = true) -> Observable<CLLocationCoordinate2D?> {
    if requestPermission {
      locationManager.requestWhenInUseAuthorization()
    }

    locationManager.startUpdatingLocation()

    return location
      .take(1)
      .do(onCompleted: { [weak self] in
        self?.locationManager.stopUpdatingLocation()
      })
  }

}
