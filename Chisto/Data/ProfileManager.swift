//
//  ProfileManager.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import ObjectMapper

class ProfileManager {
  
  let disposeBag = DisposeBag()

  static let instance = ProfileManager()
  private let profileKey = "profileId"

  let userProfile: Variable<Profile>
  
  func updateProfile(closure: ((Profile) -> Void)) {
    let profile = userProfile.value
    let realm = try! Realm()
    try! realm.write {
      closure(profile)
    }
    userProfile.value = profile
  }

  func logout() {
    let profile = userProfile.value
    let realm = try! Realm()
    let newProfile = Profile()
    try! realm.write {
      newProfile.city = profile.city
      realm.delete(profile)
      realm.add(newProfile)
      userProfile.value = newProfile
    }
    UserDefaults.standard.set(newProfile.id, forKey: profileKey)
  }
  
  init() {
    var profile: Profile

    let realm = RealmManager.instance.uiRealm
    
    if let profileId = UserDefaults.standard.value(forKey: profileKey),
      let savedProfile = realm.object(ofType: Profile.self, forPrimaryKey: profileId) {
      profile = savedProfile
    } else {
      profile = Profile()
      try! realm.write {
        realm.add(profile)
      }
      UserDefaults.standard.set(profile.id, forKey: profileKey)
    }

    self.userProfile = Variable(profile)
  }
}
