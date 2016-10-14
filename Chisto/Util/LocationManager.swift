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
    private (set) var autorized: Driver<Bool>
    private (set) var location: Observable<CLLocationCoordinate2D?>
    
    private let locationManager = CLLocationManager()
    
    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        autorized = locationManager.rx.didChangeAuthorizationStatus
            .startWith(CLLocationManager.authorizationStatus())
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
        }
        
        location = locationManager.rx.didUpdateLocations
            .filter { $0.count > 0 }
            .map { $0.last!.coordinate }
    }
    
    func locateDevice() -> Observable<CLLocationCoordinate2D?> {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        return location.take(1)
            .do(onCompleted: { [weak self] in
                self?.locationManager.stopUpdatingLocation()
                })

    }
    
}
