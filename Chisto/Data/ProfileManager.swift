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
  }
  
  init() {
    var profile: Profile
    
    if let profileId = UserDefaults.standard.value(forKey: profileKey),
      let savedProfile = uiRealm.object(ofType: Profile.self, forPrimaryKey: profileId) {
      profile = savedProfile
    } else {
      profile = Profile()
      try! uiRealm.write {
        uiRealm.add(profile)
      }
      UserDefaults.standard.set(profile.id, forKey: profileKey)
    }

    self.userProfile = Variable(profile)
    
    let observableProfile = uiRealm.observableObject(type: Profile.self, primaryKey: profile.id)
    observableProfile.filter { $0 != nil}
      .map { $0! }
      .bindTo(userProfile)
      .addDisposableTo(disposeBag)
  }
}
