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

class ProfileManager {
  
  let disposeBag = DisposeBag()

  static let instance = ProfileManager()
  private let profileKey = "profileId"

  let userProfile: Profile
  
  var apiToken: Observable<String?>
  
  // TODO: refactor
  func updateProfile(closure: ((Profile) -> Void)) {
    let realm = try! Realm()
    
    try! realm.write {
      closure(userProfile)
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

    self.userProfile = profile
    self.apiToken = uiRealm.observableObject(type: Profile.self, primaryKey: profile.id).map { $0?.apiToken }
    
    UserDefaults.standard.set(profile.id, forKey: profileKey)
  }
}
