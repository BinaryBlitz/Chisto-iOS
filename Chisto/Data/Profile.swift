//
//  Profile.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

class Profile: ServerObjct {
  dynamic var city: City? = nil
  dynamic var firstName: String = ""
  dynamic var lastName: String = ""
  dynamic var phone: String = ""
  dynamic var street: String = ""
  dynamic var building: String = ""
  dynamic var apartment: String = ""
}
