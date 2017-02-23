//
//  City.swift
//  Chisto
//
//  Created by Алексей on 04.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

class City: ServerObject {

  dynamic var name: String = ""
  dynamic var latitude: Double = 0.0
  dynamic var longitude: Double = 0.0

  override func mapping(map: Map) {
    super.mapping(map: map)
    name <- map["name"]
    latitude <- map["latitude"]
    longitude <- map["latitude"]
  }

  func distanceTo(_ point: CLLocationCoordinate2D?) -> Double {
    guard let point = point else { return 0 }
    return pow(latitude - point.latitude, 2) + pow(longitude - point.longitude, 2)
  }

}
