//
//  ProfileManager.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift

class ProfileManager {
  static let instance = ProfileManager()
  private let profileKey = "profileId"
  
  let userProfile: Profile?
  
  let userCityDidChange = PublishSubject<Void>()
  
  func saveUserCity(city: City?) {
    try! uiRealm.write {
      userProfile?.city = city
    }
    userCityDidChange.onNext()
  }
  
  init() {
    if let profileId = UserDefaults.standard.value(forKey: profileKey) {
      self.userProfile = uiRealm.object(ofType: Profile.self, forPrimaryKey: profileId)
    } else {
      let profile = Profile()
      try! uiRealm.write {
        uiRealm.add(profile)
      }
      self.userProfile = profile
      UserDefaults.standard.set(profile.id, forKey: profileKey)
    }
  }

}
