//
//  RxCLLocationManagerDelegateProxy.swift
//  RxCocoa
//  https://github.com/ReactiveX/RxSwift/commit/f4022561b8c9018b45f48fe67a7cdd36bd6fa9af
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreLocation

#if !RX_NO_MODULE

import RxSwift
import RxCocoa

#endif

class RxCLLocationManagerDelegateProxy: DelegateProxy<AnyObject, Any>, CLLocationManagerDelegate, DelegateProxyType {
    static func currentDelegate(for object: AnyObject) -> Any? {
        let locationManager: CLLocationManager = object as! CLLocationManager
        return locationManager.delegate
    }
    
    static func registerKnownImplementations() {
        return
    }
    
    static func setCurrentDelegate(_ delegate: Any?, to object: AnyObject) {
        return
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let locationManager: CLLocationManager = object as! CLLocationManager
        locationManager.delegate = delegate as? CLLocationManagerDelegate
    }
}
