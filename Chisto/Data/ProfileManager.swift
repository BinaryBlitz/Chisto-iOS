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
    
  func updateProfile(closure: ((Profile) -> Void)) {
    guard let profile = userProfile else { return }
    try! uiRealm.write {
      closure(profile)
    }

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
